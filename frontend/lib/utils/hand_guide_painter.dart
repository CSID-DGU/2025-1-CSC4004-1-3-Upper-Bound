import 'package:flutter/material.dart';

class HandGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // 타원의 중심 위치
    final center = Offset(size.width * 0.25, size.height * 0.5);

    // 타원의 사각형 영역 (Rect)
    final rect = Rect.fromCenter(
      center: center,
      width: size.width * 0.07,
      height: size.height * 0.13,
    );

    canvas.drawOval(rect, paint);
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
