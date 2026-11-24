import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/audio/sound_service.dart';
import '../models/ludo_models.dart';

class LudoController extends ChangeNotifier {
  final List<LudoPlayer> players;
  final bool isQuickRush; // 2 tokens vs 4 tokens
  int currentPlayerIndex = 0;
  int currentDiceValue = 1;
  bool isDiceRolling = false;
  bool hasRolledDice = false;
  int consecutiveSixes = 0;
  List<LudoToken> movableTokens = [];
  bool isGameOver = false;
  LudoPlayer? winner;

  LudoController({
    required int playerCount,
    required bool vsAI,
    required this.isQuickRush,
  }) : players = _createPlayers(playerCount, vsAI, isQuickRush ? 2 : 4);

  static List<LudoPlayer> _createPlayers(int count, bool vsAI, int tokenCount) {
    final colors = [LudoColor.red, LudoColor.green, LudoColor.yellow, LudoColor.blue];
    final displayColors = [
      const Color(0xFFE53935),
      const Color(0xFF43A047),
      const Color(0xFFFFB300),
      const Color(0xFF1E88E5),
    ];
    final names = ['Red', 'Green', 'Yellow', 'Blue'];

    return List.generate(count, (i) {
      final isAiPlayer = vsAI && i > 0;
      return LudoPlayer(
        color: colors[i],
        name: isAiPlayer ? '${names[i]} (Bot)' : names[i],
        isAI: isAiPlayer,
        displayColor: displayColors[i],
        tokenCount: tokenCount,
      );
    });
  }

  LudoPlayer get currentPlayer => players[currentPlayerIndex];

  Future<void> rollDice() async {
    if (isDiceRolling || hasRolledDice || isGameOver) return;

    isDiceRolling = true;
    notifyListeners();

    SoundService().playDiceRoll();

    // Dice animation frames
    for (int i = 0; i < 7; i++) {
      currentDiceValue = Random().nextInt(6) + 1;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 60));
    }

    currentDiceValue = Random().nextInt(6) + 1;
    isDiceRolling = false;
    hasRolledDice = true;

    // Check consecutive 6s
    if (currentDiceValue == 6) {
      consecutiveSixes++;
      if (consecutiveSixes == 3) {
        // Bust on 3 sixes! Turn passes
        consecutiveSixes = 0;
        await Future.delayed(const Duration(milliseconds: 500));
        _passTurn();
        return;
      }
    } else {
      consecutiveSixes = 0;
    }

    _calculateMovableTokens();
    notifyListeners();

    // Auto-move or AI move
    if (movableTokens.isEmpty) {
      // No move possible, pass turn after brief pause
      await Future.delayed(const Duration(milliseconds: 700));
      _passTurn();
    } else if (currentPlayer.isAI) {
      await Future.delayed(const Duration(milliseconds: 600));
      _performAIMove();
    } else if (movableTokens.length == 1 && movableTokens.first.isAtBase && currentDiceValue == 6) {
      // Auto unlock token if it's the only choice
      await Future.delayed(const Duration(milliseconds: 300));
      moveToken(movableTokens.first);
    }
  }

  void _calculateMovableTokens() {
    movableTokens.clear();
    for (final token in currentPlayer.tokens) {
      if (token.isFinished) continue;

      if (token.isAtBase) {
        if (currentDiceValue == 6) {
          movableTokens.add(token);
        }
      } else {
        if (token.step + currentDiceValue <= 56) {
          movableTokens.add(token);
        }
      }
    }
  }

  Future<void> moveToken(LudoToken token) async {
    if (!movableTokens.contains(token) || isGameOver) return;

    movableTokens.clear();
    notifyListeners();

    bool extraTurn = false;

    if (token.isAtBase) {
      // Unlock to start square (step 0)
      token.step = 0;
      SoundService().playTokenMove();
      extraTurn = true; // Rolling a 6 already gives extra turn
    } else {
      // Move step-by-step
      for (int i = 0; i < currentDiceValue; i++) {
        token.step++;
        SoundService().playTokenMove();
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (token.step == 56) {
        // Token reached goal!
        extraTurn = true;
        SoundService().playVictory();
      } else if (token.step < 51) {
        // Check capture on common path
        final captured = _checkForCapture(token);
        if (captured) {
          extraTurn = true;
          SoundService().playCapture();
        }
      }
    }

    // Check winner
    if (currentPlayer.hasFinishedAll) {
      currentPlayer.isWinner = true;
      isGameOver = true;
      winner = currentPlayer;
      notifyListeners();
      return;
    }

    // Pass turn or grant extra roll
    if (extraTurn || currentDiceValue == 6) {
      hasRolledDice = false;
      notifyListeners();
      if (currentPlayer.isAI) {
        await Future.delayed(const Duration(milliseconds: 700));
        rollDice();
      }
    } else {
      _passTurn();
    }
  }

  bool _checkForCapture(LudoToken attackingToken) {
    final startOffset = LudoPathData.getStartOffset(attackingToken.color);
    final globalIndex = (startOffset + attackingToken.step) % 52;

    if (LudoPathData.safeGlobalSteps.contains(globalIndex)) {
      return false; // Safe square! No capture
    }

    bool capturedAny = false;
    for (final otherPlayer in players) {
      if (otherPlayer.color == attackingToken.color) continue;

      final otherOffset = LudoPathData.getStartOffset(otherPlayer.color);
      for (final otherToken in otherPlayer.tokens) {
        if (otherToken.isAtBase || otherToken.isFinished || otherToken.isInHomeStretch) continue;

        final otherGlobalIndex = (otherOffset + otherToken.step) % 52;
        if (otherGlobalIndex == globalIndex) {
          // CAPTURE! Send opponent back to base
          otherToken.step = -1;
          capturedAny = true;
        }
      }
    }
    return capturedAny;
  }

  void _performAIMove() {
    if (movableTokens.isEmpty) return;

    // AI Strategic scoring:
    // 1. Capture opponent (Score 100)
    // 2. Reach goal (Score 80)
    // 3. Unlock token from base (Score 60)
    // 4. Enter home stretch safely (Score 50)
    // 5. Advance furthest token (Score 20)
    LudoToken bestToken = movableTokens.first;
    int bestScore = -1;

    for (final token in movableTokens) {
      int score = 0;
      if (token.isAtBase) {
        score = 60;
      } else {
        final targetStep = token.step + currentDiceValue;
        if (targetStep == 56) {
          score = 80;
        } else if (targetStep > 50) {
          score = 50;
        } else {
          // Check if can capture
          final startOffset = LudoPathData.getStartOffset(token.color);
          final targetGlobal = (startOffset + targetStep) % 52;
          if (!LudoPathData.safeGlobalSteps.contains(targetGlobal)) {
            for (final p in players) {
              if (p.color == token.color) continue;
              final pOffset = LudoPathData.getStartOffset(p.color);
              for (final t in p.tokens) {
                if (!t.isAtBase && !t.isFinished && !t.isInHomeStretch) {
                  if ((pOffset + t.step) % 52 == targetGlobal) {
                    score = 100;
                  }
                }
              }
            }
          }
          if (score == 0) {
            score = 20 + token.step; // Advance furthest token
          }
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestToken = token;
      }
    }

    moveToken(bestToken);
  }

  void _passTurn() {
    hasRolledDice = false;
    movableTokens.clear();
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    notifyListeners();

    if (currentPlayer.isAI && !isGameOver) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!isGameOver) rollDice();
      });
    }
  }

  void resetGame() {
    currentPlayerIndex = 0;
    currentDiceValue = 1;
    isDiceRolling = false;
    hasRolledDice = false;
    consecutiveSixes = 0;
    movableTokens.clear();
    isGameOver = false;
    winner = null;

    for (final p in players) {
      p.isWinner = false;
      for (final t in p.tokens) {
        t.step = -1;
      }
    }
    notifyListeners();
  }
}
