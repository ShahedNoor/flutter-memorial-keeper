import 'package:flutter/material.dart';

/// Pixel-perfect 4-color official Google 'G' logo rendered cleanly via CustomPainter.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 48.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()..isAntiAlias = true;

    // 1. Blue path
    paint.color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(46.98, 24.55)
      ..cubicTo(46.98, 22.84, 46.82, 21.2, 46.53, 19.62)
      ..lineTo(24, 19.62)
      ..lineTo(24, 28.71)
      ..lineTo(37.01, 28.71)
      ..cubicTo(36.42, 31.78, 34.62, 34.39, 31.95, 36.14)
      ..lineTo(31.95, 42.42)
      ..lineTo(39.92, 42.42)
      ..cubicTo(44.59, 38.12, 46.98, 31.84, 46.98, 24.55)
      ..close();
    canvas.drawPath(bluePath, paint);

    // 2. Green path
    paint.color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(24, 48)
      ..cubicTo(30.48, 48, 35.93, 45.85, 39.92, 42.42)
      ..lineTo(31.95, 36.14)
      ..cubicTo(29.74, 37.62, 26.96, 38.51, 24, 38.51)
      ..cubicTo(17.72, 38.51, 12.39, 34.25, 10.49, 28.53)
      ..lineTo(2.26, 28.53)
      ..lineTo(2.26, 34.92)
      ..cubicTo(6.31, 42.97, 14.5, 48, 24, 48)
      ..close();
    canvas.drawPath(greenPath, paint);

    // 3. Yellow path
    paint.color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(10.49, 28.53)
      ..cubicTo(10.01, 27.09, 9.73, 25.56, 9.73, 24)
      ..cubicTo(9.73, 22.44, 10.01, 20.91, 10.49, 19.47)
      ..lineTo(10.49, 13.08)
      ..lineTo(2.26, 13.08)
      ..cubicTo(0.82, 16.03, 0, 19.92, 0, 24)
      ..cubicTo(0, 28.08, 0.82, 31.97, 2.26, 34.92)
      ..lineTo(10.49, 28.53)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // 4. Red path
    paint.color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(24, 9.49)
      ..cubicTo(27.53, 9.49, 30.7, 10.71, 33.19, 13.09)
      ..lineTo(39.99, 6.29)
      ..cubicTo(35.91, 2.49, 30.46, 0, 24, 0)
      ..cubicTo(14.5, 0, 6.31, 5.03, 2.26, 13.08)
      ..lineTo(10.49, 19.47)
      ..cubicTo(12.39, 13.75, 17.72, 9.49, 24, 9.49)
      ..close();
    canvas.drawPath(redPath, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
