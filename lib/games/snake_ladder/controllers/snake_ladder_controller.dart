import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/audio/sound_service.dart';
import '../models/snake_ladder_model.dart';

class SnakeLadderController extends ChangeNotifier {
  final List<SnakePlayer> players;
  int currentPlayerIndex = 0;
  int currentDiceValue = 1;
  bool isRolling = false;
  bool isMoving = false;
  bool isGameOver = false;
  SnakePlayer? winner;
  String statusMessage = "Roll the dice to start!";

  SnakeLadderController({required int playerCount, required bool vsAI})
      : players = _createPlayers(playerCount, vsAI);

  static List<SnakePlayer> _createPlayers(int count, bool vsAI) {
    final colors = [
      const Color(0xFFE53935),
      const Color(0xFF1E88E5),
      const Color(0xFF43A047),
      const Color(0xFFFFB300),
    ];
    final names = ['Player 1', 'Player 2', 'Player 3', 'Player 4'];

    return List.generate(count, (i) {
      final isBot = vsAI && i > 0;
      return SnakePlayer(
        id: i,
        name: isBot ? 'Bot ${i + 1}' : names[i],
        color: colors[i],
        isAI: isBot,
      );
    });
  }

  SnakePlayer get currentPlayer => players[currentPlayerIndex];

  Future<void> rollDice() async {
    if (isRolling || isMoving || isGameOver) return;

    isRolling = true;
    notifyListeners();
    SoundService().playDiceRoll();

    for (int i = 0; i < 7; i++) {
      currentDiceValue = Random().nextInt(6) + 1;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 60));
    }

    currentDiceValue = Random().nextInt(6) + 1;
    isRolling = false;
    notifyListeners();

    await _processMove();
  }

  Future<void> _processMove() async {
    isMoving = true;
    final player = currentPlayer;

    // Check if player needs 1 to enter or can move directly
    int target = (player.position == 0) ? currentDiceValue : player.position + currentDiceValue;

    if (target > 100) {
      // Must reach 100 exactly
      statusMessage = "${player.name} needed exact roll!";
      isMoving = false;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 800));
      _passTurn();
      return;
    }

    // Move step-by-step
    final startPos = max(1, player.position);
    for (int step = startPos; step <= target; step++) {
      player.position = step;
      SoundService().playTokenMove();
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 140));
    }

    // Check Ladder
    if (SnakeLadderRules.ladders.containsKey(player.position)) {
      final top = SnakeLadderRules.ladders[player.position]!;
      statusMessage = "🎉 ${player.name} climbed a ladder to $top!";
      SoundService().playLadderClimb();
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 600));
      player.position = top;
      notifyListeners();
    }
    // Check Snake
    else if (SnakeLadderRules.snakes.containsKey(player.position)) {
      final tail = SnakeLadderRules.snakes[player.position]!;
      statusMessage = "🐍 Ouch! Snake bit ${player.name} down to $tail!";
      SoundService().playSnakeBite();
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 600));
      player.position = tail;
      notifyListeners();
    }

    // Check Win
    if (player.hasWon) {
      isGameOver = true;
      winner = player;
      statusMessage = "🏆 ${player.name} reached 100 and WON!";
      SoundService().playVictory();
      isMoving = false;
      notifyListeners();
      return;
    }

    isMoving = false;
    notifyListeners();

    // Bonus roll on rolling a 6
    if (currentDiceValue == 6) {
      statusMessage = "${player.name} rolled a 6! Roll again.";
      notifyListeners();
      if (player.isAI) {
        await Future.delayed(const Duration(milliseconds: 800));
        rollDice();
      }
    } else {
      _passTurn();
    }
  }

  void _passTurn() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    statusMessage = "Turn: ${currentPlayer.name}";
    notifyListeners();

    if (currentPlayer.isAI && !isGameOver) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!isGameOver) rollDice();
      });
    }
  }

  void resetGame() {
    currentPlayerIndex = 0;
    currentDiceValue = 1;
    isRolling = false;
    isMoving = false;
    isGameOver = false;
    winner = null;
    statusMessage = "Roll the dice to start!";
    for (final p in players) {
      p.position = 0;
    }
    notifyListeners();
  }
}
