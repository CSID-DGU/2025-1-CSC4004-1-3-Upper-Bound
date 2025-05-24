import 'package:flutter/material.dart';

class HandGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width * 0.25, size.height * 0.5);

    final rect = Rect.fromCenter(
      center: center,
      width: size.width * 0.07,
      height: size.height * 0.13,
    );

    canvas.drawOval(rect, paint);

    final offsetX = size.width * 0.07;
    final leftX = center.dx + offsetX;
    final rightX = center.dx + offsetX;

    final lineTopX = center.dy - size.height * 0.45;
    final lineBottomX = center.dy + size.height * -0.4;

    final lineTopY = center.dy - size.height * -0.45;
    final lineBottomY = center.dy + size.height * 0.4;

    canvas.drawLine(Offset(leftX, lineTopX), Offset(leftX, lineBottomX), paint);
    canvas.drawLine(Offset(rightX, lineTopY), Offset(rightX, lineBottomY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
