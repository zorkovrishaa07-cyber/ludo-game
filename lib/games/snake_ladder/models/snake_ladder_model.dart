import 'package:flutter/material.dart';

class SnakePlayer {
  final int id;
  final String name;
  final Color color;
  final bool isAI;
  int position; // 0 = start outside board, 1 to 100 on board

  SnakePlayer({
    required this.id,
    required this.name,
    required this.color,
    required this.isAI,
    this.position = 0,
  });

  bool get hasWon => position == 100;
}

class SnakeLadderRules {
  // Classic Snakes (Head -> Tail)
  static const Map<int, int> snakes = {
    98: 28,
    95: 56,
    92: 51,
    83: 19,
    73: 1,
    69: 33,
    64: 36,
    59: 17,
    52: 11,
    48: 9,
    44: 22,
  };

  // Classic Ladders (Bottom -> Top)
  static const Map<int, int> ladders = {
    4: 14,
    8: 30,
    21: 42,
    28: 76,
    36: 44,
    51: 67,
    71: 91,
    80: 99,
  };

  /// Convert square number 1..100 into (col, row) on a 10x10 board
  /// Square 1 is at bottom-left (col 0, row 9)
  /// Square 100 is at top-left (col 0, row 0)
  static Offset getBoardCoordinate(int square, double cellSize) {
    if (square <= 0) return Offset(0, 9 * cellSize);
    final zeroIdx = (square - 1).clamp(0, 99);
    final rowFromBottom = zeroIdx ~/ 10;
    final row = 9 - rowFromBottom;
    int col;

    if (rowFromBottom % 2 == 0) {
      // Left to right
      col = zeroIdx % 10;
    } else {
      // Right to left
      col = 9 - (zeroIdx % 10);
    }

    return Offset(col * cellSize + cellSize / 2, row * cellSize + cellSize / 2);
  }
}
