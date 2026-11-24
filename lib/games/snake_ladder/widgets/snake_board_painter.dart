import 'dart:math';
import 'package:flutter/material.dart';
import '../controllers/snake_ladder_controller.dart';
import '../models/snake_ladder_model.dart';

class SnakeBoardPainter extends CustomPainter {
  final SnakeLadderController controller;

  SnakeBoardPainter({required this.controller});

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / 10.0;
    final cellBorderPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Palette for alternating checkered board squares
    final colors = [
      const Color(0xFFFFF9C4),
      const Color(0xFFFFCDD2),
      const Color(0xFFC8E6C9),
      const Color(0xFFBBDEFB),
    ];

    // 1. Draw 100 Squares
    for (int sq = 1; sq <= 100; sq++) {
      final coord = SnakeLadderRules.getBoardCoordinate(sq, cellSize);
      final rect = Rect.fromCenter(center: coord, width: cellSize, height: cellSize);
      final bg = Paint()..color = colors[sq % colors.length];

      canvas.drawRect(rect, bg);
      canvas.drawRect(rect, cellBorderPaint);

      // Square number text
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$sq',
          style: TextStyle(
            color: Colors.black87,
            fontSize: cellSize * 0.28,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(rect.left + 4, rect.top + 2),
      );
    }

    // 2. Draw Ladders
    for (final entry in SnakeLadderRules.ladders.entries) {
      _drawLadder(
        canvas,
        SnakeLadderRules.getBoardCoordinate(entry.key, cellSize),
        SnakeLadderRules.getBoardCoordinate(entry.value, cellSize),
        cellSize * 0.16,
      );
    }

    // 3. Draw Snakes
    for (final entry in SnakeLadderRules.snakes.entries) {
      _drawSnake(
        canvas,
        SnakeLadderRules.getBoardCoordinate(entry.key, cellSize),   // Head
        SnakeLadderRules.getBoardCoordinate(entry.value, cellSize), // Tail
        cellSize,
      );
    }

    // 4. Draw Player Tokens
    for (int i = 0; i < controller.players.length; i++) {
      final player = controller.players[i];
      if (player.position <= 0) continue;

      final center = SnakeLadderRules.getBoardCoordinate(player.position, cellSize);
      // Offset if multiple players are on the same square
      final offsetMultiplier = (i - (controller.players.length - 1) / 2.0);
      final tokenCenter = Offset(center.dx + offsetMultiplier * (cellSize * 0.18), center.dy);

      // Shadow
      canvas.drawCircle(
        tokenCenter.translate(0, 2),
        cellSize * 0.32,
        Paint()..color = Colors.black38,
      );

      // Body
      canvas.drawCircle(
        tokenCenter,
        cellSize * 0.32,
        Paint()..color = player.color,
      );

      // Inner white ring & center dot
      canvas.drawCircle(
        tokenCenter,
        cellSize * 0.20,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        tokenCenter,
        cellSize * 0.10,
        Paint()..color = player.color,
      );
    }
  }

  void _drawLadder(Canvas canvas, Offset bottom, Offset top, double width) {
    final ladderPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final dx = top.dx - bottom.dx;
    final dy = top.dy - bottom.dy;
    final angle = atan2(dy, dx);
    final perpAngle = angle + pi / 2;

    final offX = cos(perpAngle) * width / 2;
    final offY = sin(perpAngle) * width / 2;

    final b1 = Offset(bottom.dx - offX, bottom.dy - offY);
    final b2 = Offset(bottom.dx + offX, bottom.dy + offY);
    final t1 = Offset(top.dx - offX, top.dy - offY);
    final t2 = Offset(top.dx + offX, top.dy + offY);

    // Left and Right rails
    canvas.drawLine(b1, t1, ladderPaint);
    canvas.drawLine(b2, t2, ladderPaint);

    // Rungs
    const rungsCount = 6;
    final rungPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 2.5;

    for (int i = 1; i <= rungsCount; i++) {
      final t = i / (rungsCount + 1);
      final r1 = Offset.lerp(b1, t1, t)!;
      final r2 = Offset.lerp(b2, t2, t)!;
      canvas.drawLine(r1, r2, rungPaint);
    }
  }

  void _drawSnake(Canvas canvas, Offset head, Offset tail, double cellSize) {
    final snakePaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Curved wavy body
    final path = Path();
    path.moveTo(head.dx, head.dy);

    final mid1 = Offset(
      head.dx + (tail.dx - head.dx) * 0.33 + 15,
      head.dy + (tail.dy - head.dy) * 0.33 - 15,
    );
    final mid2 = Offset(
      head.dx + (tail.dx - head.dx) * 0.66 - 15,
      head.dy + (tail.dy - head.dy) * 0.66 + 15,
    );

    path.cubicTo(mid1.dx, mid1.dy, mid2.dx, mid2.dy, tail.dx, tail.dy);
    canvas.drawPath(path, snakePaint);

    // Snake Head
    final headPaint = Paint()..color = const Color(0xFF1B5E20);
    canvas.drawCircle(head, cellSize * 0.22, headPaint);

    // Red tongue / eyes
    canvas.drawCircle(Offset(head.dx - 3, head.dy - 3), 2.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(head.dx + 3, head.dy - 3), 2.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant SnakeBoardPainter oldDelegate) => true;
}
