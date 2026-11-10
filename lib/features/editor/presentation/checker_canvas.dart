import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';

/// Latar transparan bermotif papan catur (App.tsx `.checker`).
class CheckerCanvas extends StatelessWidget {
  const CheckerCanvas({super.key, this.squareSize = 12.0});

  final double squareSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CustomPaint(
      size: Size.infinite,
      painter: _CheckerPainter(
        color1: colors.surface,
        color2: colors.line.withValues(alpha: 0.3),
        size: squareSize,
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  const _CheckerPainter({
    required this.color1,
    required this.color2,
    required this.size,
  });

  final Color color1;
  final Color color2;
  final double size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint1 = Paint()..color = color1;
    final paint2 = Paint()..color = color2;

    canvas.drawRect(Offset.zero & canvasSize, paint1);

    final cols = (canvasSize.width / size).ceil();
    final rows = (canvasSize.height / size).ceil();

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if ((r + c) % 2 == 1) {
          canvas.drawRect(
            Rect.fromLTWH(c * size, r * size, size, size),
            paint2,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckerPainter old) =>
      old.color1 != color1 || old.color2 != color2 || old.size != size;
}
