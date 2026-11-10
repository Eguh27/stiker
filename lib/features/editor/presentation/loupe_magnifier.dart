import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/widgets/sticker_art.dart';

import 'checker_canvas.dart';

/// Pembesar (loupe magnifier) di pojok kanvas (App.tsx `.loupe`).
class LoupeMagnifier extends StatelessWidget {
  const LoupeMagnifier({super.key, this.artIndex = 6, this.diameter = 80.0});

  final int artIndex;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.line, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const CheckerCanvas(squareSize: 8),
          Transform.scale(
            scale: 1.5,
            child: StickerArt(
              color: colors.stickerPink,
              label: 'Sticker',
              shape: StickerArtShape.burst,
              small: true,
            ),
          ),
          // Crosshair
          CustomPaint(
            size: Size(diameter, diameter),
            painter: _CrosshairPainter(color: colors.accent),
          ),
        ],
      ),
    );
  }
}

class _CrosshairPainter extends CustomPainter {
  const _CrosshairPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.0;
    final center = size.center(Offset.zero);
    canvas.drawLine(
      Offset(center.dx - 10, center.dy),
      Offset(center.dx + 10, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 10),
      Offset(center.dx, center.dy + 10),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CrosshairPainter old) => old.color != color;
}
