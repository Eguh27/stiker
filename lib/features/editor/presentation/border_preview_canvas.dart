import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';
import 'package:sticker_studio/core/widgets/sticker_art.dart';

import 'checker_canvas.dart';

/// Pratinjau kanvas stiker dengan border real-time (App.tsx `.border-canvas`).
class BorderPreviewCanvas extends StatelessWidget {
  const BorderPreviewCanvas({
    super.key,
    required this.width,
    required this.feather,
    required this.color,
  });

  final double width;
  final double feather;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strokeWidth = (width / 3.0).clamp(2.0, 24.0);
    final blurRadius = (feather / 4.0).clamp(0.0, 20.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        const CheckerCanvas(),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              if (width > 0)
                BoxShadow(
                  color: color.withValues(alpha: 0.8),
                  blurRadius: blurRadius,
                  spreadRadius: strokeWidth,
                ),
            ],
          ),
          child: StickerArt(
            color: colors.stickerPeach,
            label: 'Border Art',
            shape: StickerArtShape.burst,
          ),
        ),
        Positioned(
          bottom: AppSpacing.s4,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s3,
              vertical: AppSpacing.s1,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceSolid.withValues(alpha: 0.85),
              borderRadius: AppRadius.pill,
              border: Border.all(color: colors.line),
            ),
            child: Text(
              'Preview ${width.round()}px',
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: colors.text2),
            ),
          ),
        ),
      ],
    );
  }
}
