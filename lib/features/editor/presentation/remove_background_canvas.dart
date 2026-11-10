import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';
import 'package:sticker_studio/core/widgets/sticker_art.dart';

import 'checker_canvas.dart';
import 'loupe_magnifier.dart';

/// Area kanvas utama penghapus background dengan cursor kuas dan loupe.
class RemoveBackgroundCanvas extends StatelessWidget {
  const RemoveBackgroundCanvas({super.key, required this.brushSize});

  final double brushSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      alignment: Alignment.center,
      children: [
        const CheckerCanvas(),
        StickerArt(
          color: colors.stickerLavender,
          label: 'Subject',
          shape: StickerArtShape.burst,
        ),
        Container(
          width: brushSize,
          height: brushSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colors.accent, width: 2),
            color: colors.accent.withValues(alpha: 0.1),
          ),
        ),
        const Positioned(
          top: AppSpacing.s4,
          right: AppSpacing.s4,
          child: LoupeMagnifier(),
        ),
      ],
    );
  }
}
