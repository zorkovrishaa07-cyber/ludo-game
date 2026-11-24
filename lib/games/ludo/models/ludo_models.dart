import 'package:flutter/material.dart';

enum LudoColor { red, green, yellow, blue }

class LudoToken {
  final int id;
  final LudoColor color;
  int step; // -1: in base, 0-50: common path, 51-55: home column, 56: finished

  LudoToken({required this.id, required this.color, this.step = -1});

  bool get isAtBase => step == -1;
  bool get isFinished => step == 56;
  bool get isInHomeStretch => step >= 51 && step < 56;
}

class LudoPlayer {
  final LudoColor color;
  final String name;
  final bool isAI;
  final Color displayColor;
  final List<LudoToken> tokens;
  bool isWinner;

  LudoPlayer({
    required this.color,
    required this.name,
    required this.isAI,
    required this.displayColor,
    required int tokenCount,
    this.isWinner = false,
  }) : tokens = List.generate(
          tokenCount,
          (index) => LudoToken(id: index, color: color),
        );

  int get finishedTokenCount => tokens.where((t) => t.isFinished).length;
  bool get hasFinishedAll => finishedTokenCount == tokens.length;
}

/// Helper mapping 15x15 board coordinates
class LudoPathData {
  // Global 52 common steps on 15x15 grid (row, col)
  static const List<Point<int>> commonPath = [
    Point(6, 1), Point(6, 2), Point(6, 3), Point(6, 4), Point(6, 5), // Red start & path
    Point(5, 6), Point(4, 6), Point(3, 6), Point(2, 6), Point(1, 6), Point(0, 6),
    Point(0, 7),
    Point(0, 8), Point(1, 8), Point(2, 8), Point(3, 8), Point(4, 8), Point(5, 8), // Green path
    Point(6, 9), Point(6, 10), Point(6, 11), Point(6, 12), Point(6, 13), Point(6, 14),
    Point(7, 14),
    Point(8, 14), Point(8, 13), Point(8, 12), Point(8, 11), Point(8, 10), Point(8, 9), // Yellow path
    Point(9, 8), Point(10, 8), Point(11, 8), Point(12, 8), Point(13, 8), Point(14, 8),
    Point(14, 7),
    Point(14, 6), Point(13, 6), Point(12, 6), Point(11, 6), Point(10, 6), Point(9, 6), // Blue path
    Point(8, 5), Point(8, 4), Point(8, 3), Point(8, 2), Point(8, 1), Point(8, 0),
    Point(7, 0),
    Point(6, 0),
  ];

  // Offset index where each color enters the common path
  static int getStartOffset(LudoColor color) {
    switch (color) {
      case LudoColor.red: return 0;
      case LudoColor.green: return 13;
      case LudoColor.yellow: return 26;
      case LudoColor.blue: return 39;
    }
  }

  // Home columns for each color (5 steps leading to center)
  static List<Point<int>> getHomeColumn(LudoColor color) {
    switch (color) {
      case LudoColor.red:
        return const [Point(7, 1), Point(7, 2), Point(7, 3), Point(7, 4), Point(7, 5)];
      case LudoColor.green:
        return const [Point(1, 7), Point(2, 7), Point(3, 7), Point(4, 7), Point(5, 7)];
      case LudoColor.yellow:
        return const [Point(7, 13), Point(7, 12), Point(7, 11), Point(7, 10), Point(7, 9)];
      case LudoColor.blue:
        return const [Point(13, 7), Point(12, 7), Point(11, 7), Point(10, 7), Point(9, 7)];
    }
  }

  // Safe global steps (stars) where tokens cannot be captured
  static const Set<int> safeGlobalSteps = {0, 8, 13, 21, 26, 34, 39, 47};

  // Base slot coordinates for each player's 4 tokens
  static List<Point<double>> getBaseSlots(LudoColor color) {
    switch (color) {
      case LudoColor.red:
        return const [Point(2.0, 2.0), Point(2.0, 3.5), Point(3.5, 2.0), Point(3.5, 3.5)];
      case LudoColor.green:
        return const [Point(2.0, 11.0), Point(2.0, 12.5), Point(3.5, 11.0), Point(3.5, 12.5)];
      case LudoColor.yellow:
        return const [Point(11.0, 11.0), Point(11.0, 12.5), Point(12.5, 11.0), Point(12.5, 12.5)];
      case LudoColor.blue:
        return const [Point(11.0, 2.0), Point(11.0, 3.5), Point(12.5, 2.0), Point(12.5, 3.5)];
    }
  }
}

class Point<T extends num> {
  final T x;
  final T y;
  const Point(this.x, this.y);
}
