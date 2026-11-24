import 'package:flutter/material.dart';
import '../controllers/ludo_controller.dart';
import '../models/ludo_models.dart';

class LudoBoardPainter extends CustomPainter {
  final LudoController controller;
  final Animation<double>? pulseAnimation;

  LudoBoardPainter({required this.controller, this.pulseAnimation})
      : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / 15.0;
    final bgPaint = Paint()..color = const Color(0xFFF7F7F7);
    final borderPaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 1. Draw Player Home Bases (6x6 cells each)
    _drawBase(canvas, 0, 0, 6, 6, cellSize, const Color(0xFFE53935), const Color(0xFFFFCDD2)); // Red
    _drawBase(canvas, 9, 0, 6, 6, cellSize, const Color(0xFF43A047), const Color(0xFFC8E6C9)); // Green
    _drawBase(canvas, 9, 9, 6, 6, cellSize, const Color(0xFFFFB300), const Color(0xFFFFF9C4)); // Yellow
    _drawBase(canvas, 0, 9, 6, 6, cellSize, const Color(0xFF1E88E5), const Color(0xFFBBDEFB)); // Blue

    // 2. Draw Center Triangles (Goal area)
    _drawCenterGoal(canvas, cellSize);

    // 3. Draw Path Grid Cells
    for (int r = 0; r < 15; r++) {
      for (int c = 0; c < 15; c++) {
        // Skip bases and center
        if ((r < 6 && c < 6) || (r < 6 && c >= 9) || (r >= 9 && c < 6) || (r >= 9 && c >= 9)) continue;
        if (r >= 6 && r <= 8 && c >= 6 && c <= 8) continue;

        final rect = Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize);
        
        // Color home lanes
        Color cellColor = Colors.white;
        if (r == 7 && c >= 1 && c <= 5) cellColor = const Color(0xFFE53935); // Red lane
        if (c == 7 && r >= 1 && r <= 5) cellColor = const Color(0xFF43A047); // Green lane
        if (r == 7 && c >= 9 && c <= 13) cellColor = const Color(0xFFFFB300); // Yellow lane
        if (c == 7 && r >= 9 && r <= 13) cellColor = const Color(0xFF1E88E5); // Blue lane

        // Starting squares
        if (r == 6 && c == 1) cellColor = const Color(0xFFE53935);
        if (r == 1 && c == 8) cellColor = const Color(0xFF43A047);
        if (r == 8 && c == 13) cellColor = const Color(0xFFFFB300);
        if (r == 13 && c == 6) cellColor = const Color(0xFF1E88E5);

        final cellPaint = Paint()..color = cellColor;
        canvas.drawRect(rect, cellPaint);
        canvas.drawRect(rect, borderPaint);

        // Safe star indicators
        if ((r == 6 && c == 1) || (r == 2 && c == 6) ||
            (r == 1 && c == 8) || (r == 6 && c == 12) ||
            (r == 8 && c == 13) || (r == 12 && c == 8) ||
            (r == 13 && c == 6) || (r == 8 && c == 2)) {
          _drawStar(canvas, rect.center, cellSize * 0.35, Colors.white70);
        }
      }
    }

    // 4. Draw Tokens on Board & Bases
    _drawAllTokens(canvas, cellSize);
  }

  void _drawBase(Canvas canvas, int col, int row, int w, int h, double cellSize, Color borderCol, Color fillCol) {
    final rect = Rect.fromLTWH(col * cellSize, row * cellSize, w * cellSize, h * cellSize);
    canvas.drawRect(rect, Paint()..color = borderCol);
    final inner = rect.deflate(cellSize * 0.7);
    canvas.drawRRect(RRect.fromRectAndRadius(inner, const Radius.circular(12)), Paint()..color = fillCol);
  }

  void _drawCenterGoal(Canvas canvas, double cellSize) {
    final cx = 7.5 * cellSize;
    final cy = 7.5 * cellSize;

    final redPath = Path()..moveTo(6 * cellSize, 6 * cellSize)..lineTo(cx, cy)..lineTo(6 * cellSize, 9 * cellSize)..close();
    canvas.drawPath(redPath, Paint()..color = const Color(0xFFE53935));

    final greenPath = Path()..moveTo(6 * cellSize, 6 * cellSize)..lineTo(cx, cy)..lineTo(9 * cellSize, 6 * cellSize)..close();
    canvas.drawPath(greenPath, Paint()..color = const Color(0xFF43A047));

    final yellowPath = Path()..moveTo(9 * cellSize, 6 * cellSize)..lineTo(cx, cy)..lineTo(9 * cellSize, 9 * cellSize)..close();
    canvas.drawPath(yellowPath, Paint()..color = const Color(0xFFFFB300));

    final bluePath = Path()..moveTo(6 * cellSize, 9 * cellSize)..lineTo(cx, cy)..lineTo(9 * cellSize, 9 * cellSize)..close();
    canvas.drawPath(bluePath, Paint()..color = const Color(0xFF1E88E5));
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.5, paint);
  }

  void _drawAllTokens(Canvas canvas, double cellSize) {
    // Collect all tokens and their calculated screen coordinates
    for (final player in controller.players) {
      final baseSlots = LudoPathData.getBaseSlots(player.color);
      final homeCols = LudoPathData.getHomeColumn(player.color);
      final startOffset = LudoPathData.getStartOffset(player.color);

      for (int i = 0; i < player.tokens.length; i++) {
        final token = player.tokens[i];
        Offset pos;

        if (token.isAtBase) {
          final slot = baseSlots[i % baseSlots.length];
          pos = Offset(slot.y * cellSize + cellSize / 2, slot.x * cellSize + cellSize / 2);
        } else if (token.isFinished) {
          pos = Offset(7.5 * cellSize, 7.5 * cellSize);
        } else if (token.isInHomeStretch) {
          final homeIndex = token.step - 51;
          final cell = homeCols[homeIndex];
          pos = Offset(cell.y * cellSize + cellSize / 2, cell.x * cellSize + cellSize / 2);
        } else {
          final globalIndex = (startOffset + token.step) % 52;
          final cell = LudoPathData.commonPath[globalIndex];
          pos = Offset(cell.y * cellSize + cellSize / 2, cell.x * cellSize + cellSize / 2);
        }

        final isMovable = controller.movableTokens.contains(token);

        // Pulsating highlight ring if token can be moved
        if (isMovable) {
          final pulseVal = pulseAnimation != null ? pulseAnimation!.value : 1.0;
          canvas.drawCircle(
            pos,
            (cellSize * 0.5) * (0.9 + 0.2 * pulseVal),
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.5,
          );
        }

        // Token Body
        canvas.drawCircle(
          pos,
          cellSize * 0.42,
          Paint()
            ..color = player.displayColor
            ..style = PaintingStyle.fill,
        );

        // Inner 3D ring & white center dot
        canvas.drawCircle(
          pos,
          cellSize * 0.28,
          Paint()
            ..color = Colors.white.withOpacity(0.85)
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          pos,
          cellSize * 0.16,
          Paint()
            ..color = player.displayColor
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant LudoBoardPainter oldDelegate) => true;
}
