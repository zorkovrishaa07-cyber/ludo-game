import 'dart:math';
import 'package:flutter/material.dart';

class DiceWidget extends StatelessWidget {
  final int value;
  final bool isRolling;
  final bool canRoll;
  final VoidCallback onTap;
  final Color activeColor;

  const DiceWidget({
    super.key,
    required this.value,
    required this.isRolling,
    required this.canRoll,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canRoll ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: canRoll ? activeColor : Colors.grey.shade400,
            width: canRoll ? 3.5 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: canRoll ? activeColor.withOpacity(0.5) : Colors.black26,
              blurRadius: canRoll ? 14 : 6,
              spreadRadius: canRoll ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isRolling
            ? const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              )
            : CustomPaint(
                painter: _DiceDotsPainter(value: value, dotColor: activeColor),
              ),
      ),
    );
  }
}

class _DiceDotsPainter extends CustomPainter {
  final int value;
  final Color dotColor;

  _DiceDotsPainter({required this.value, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final double dotRadius = size.width * 0.09;
    final double left = size.width * 0.25;
    final double center = size.width * 0.50;
    final double right = size.width * 0.75;
    final double top = size.height * 0.25;
    final double middle = size.height * 0.50;
    final double bottom = size.height * 0.75;

    void draw(double x, double y) => canvas.drawCircle(Offset(x, y), dotRadius, paint);

    switch (value) {
      case 1:
        draw(center, middle);
        break;
      case 2:
        draw(left, top);
        draw(right, bottom);
        break;
      case 3:
        draw(left, top);
        draw(center, middle);
        draw(right, bottom);
        break;
      case 4:
        draw(left, top);
        draw(right, top);
        draw(left, bottom);
        draw(right, bottom);
        break;
      case 5:
        draw(left, top);
        draw(right, top);
        draw(center, middle);
        draw(left, bottom);
        draw(right, bottom);
        break;
      case 6:
        draw(left, top);
        draw(right, top);
        draw(left, middle);
        draw(right, middle);
        draw(left, bottom);
        draw(right, bottom);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _DiceDotsPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.dotColor != dotColor;
}
