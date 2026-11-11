import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Latar gradasi pastel + cahaya lembut + grid samar di belakang seluruh app.
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c.bgTop, c.bgMid, c.bgBottom],
              ),
            ),
          ),
        ),
        Positioned(top: -140, right: -120, child: _Glow(c.glow, 360)),
        Positioned(bottom: -160, left: -140, child: _Glow(c.bgBottom, 400)),
        RepaintBoundary(
          child: CustomPaint(painter: _GridPainter(c.lineStrong.withValues(alpha: 0.10))),
        ),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow(this.color, this.size);

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.45), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter(this.color);

  final Color color;
  static const double _gap = 36;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += _gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += _gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.color != color;
}
