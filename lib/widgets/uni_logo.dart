// ===== FILE GUIDE: lib/widgets/uni_logo.dart
// WHAT IT DOES : The Uni-Sphere globe logo (drawn in code).
// MANAGES      : Logo size and drawing.
// USED BY      : Splash and login screens.
// ======================================================================

import 'package:flutter/material.dart';

/// The Uni-Sphere mark: a frosted circle holding a line-drawn globe with a
/// mint centre dot (from the PDF login screen).
class UniLogo extends StatelessWidget {
  final double size;

  const UniLogo({super.key, this.size = 92});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Uni-Sphere logo',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: 1.4),
          boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 10))],
        ),
        child: CustomPaint(painter: _GlobePainter()),
      ),
    );
  }
}

class _GlobePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.21;
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.028;
    canvas.drawCircle(c, r, line);
    canvas.drawOval(Rect.fromCenter(center: c, width: r * 1.05, height: r * 2), line);
    canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), line);
    canvas.drawCircle(c, size.width * 0.055, Paint()..color = Color(0xFF2EC4A0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
