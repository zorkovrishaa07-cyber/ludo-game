import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/audio/sound_service.dart';
import '../models/ttt_model.dart';

class TttController extends ChangeNotifier {
  final bool vsAI;
  List<TttPiece> board = List.filled(9, TttPiece.none);
  TttPiece currentTurn = TttPiece.x;
  bool isGameOver = false;
  TttWinResult? winResult;
  int xScore = 0;
  int oScore = 0;
  int drawScore = 0;

  static const List<List<int>> winLines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
    [0, 4, 8], [2, 4, 6],             // diagonals
  ];

  TttController({required this.vsAI});

  Future<void> makeMove(int index) async {
    if (board[index] != TttPiece.none || isGameOver) return;

    board[index] = currentTurn;
    SoundService().playClick();
    _checkGameState();
    notifyListeners();

    if (!isGameOver) {
      currentTurn = (currentTurn == TttPiece.x) ? TttPiece.o : TttPiece.x;
      notifyListeners();

      if (vsAI && currentTurn == TttPiece.o) {
        await Future.delayed(const Duration(milliseconds: 500));
        _performAIMove();
      }
    }
  }

  void _performAIMove() {
    if (isGameOver) return;

    // 1. Can AI (O) win in 1 move?
    for (int i = 0; i < 9; i++) {
      if (board[i] == TttPiece.none) {
        board[i] = TttPiece.o;
        if (_checkWinner(TttPiece.o)) {
          board[i] = TttPiece.none;
          makeMove(i);
          return;
        }
        board[i] = TttPiece.none;
      }
    }

    // 2. Can Player (X) win in 1 move? Block them!
    for (int i = 0; i < 9; i++) {
      if (board[i] == TttPiece.none) {
        board[i] = TttPiece.x;
        if (_checkWinner(TttPiece.x)) {
          board[i] = TttPiece.none;
          makeMove(i);
          return;
        }
        board[i] = TttPiece.none;
      }
    }

    // 3. Take Center if available
    if (board[4] == TttPiece.none) {
      makeMove(4);
      return;
    }

    // 4. Take random available corner or edge
    final available = <int>[];
    for (int i = 0; i < 9; i++) {
      if (board[i] == TttPiece.none) available.add(i);
    }

    if (available.isNotEmpty) {
      final pick = available[Random().nextInt(available.length)];
      makeMove(pick);
    }
  }

  bool _checkWinner(TttPiece piece) {
    for (final line in winLines) {
      if (board[line[0]] == piece && board[line[1]] == piece && board[line[2]] == piece) {
        return true;
      }
    }
    return false;
  }

  void _checkGameState() {
    for (final line in winLines) {
      if (board[line[0]] != TttPiece.none &&
          board[line[0]] == board[line[1]] &&
          board[line[1]] == board[line[2]]) {
        final winner = board[line[0]];
        winResult = TttWinResult(winner: winner, winningPattern: line);
        isGameOver = true;
        if (winner == TttPiece.x) xScore++;
        if (winner == TttPiece.o) oScore++;
        SoundService().playVictory();
        return;
      }
    }

    // Check Draw
    if (!board.contains(TttPiece.none)) {
      isGameOver = true;
      winResult = const TttWinResult(winner: TttPiece.none);
      drawScore++;
    }
  }

  void resetRound() {
    board = List.filled(9, TttPiece.none);
    currentTurn = TttPiece.x;
    isGameOver = false;
    winResult = null;
    notifyListeners();
  }
}
