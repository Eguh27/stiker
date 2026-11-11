import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/sticker_art.dart';
import '../domain/sticker.dart';
import 'sticker_visuals.dart';

class StickerCard extends StatelessWidget {
  const StickerCard({super.key, required this.sticker, this.onTap});

  final Sticker sticker;
  final ValueChanged<Sticker>? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Material(
      color: colors.glassFill,
      borderRadius: AppRadius.card,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: onTap == null ? null : () => onTap!(sticker),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            border: Border.all(color: colors.glassBorder),
            boxShadow: AppShadows.glass,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (sticker.filePath != null &&
                  File(sticker.filePath!).existsSync())
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.s2),
                  child: Image.file(
                    File(sticker.filePath!),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => StickerArt(
                      color: stickerColorFor(colors, sticker.colorKind),
                      label: sticker.label,
                      shape: shapeFor(sticker.shape),
                    ),
                  ),
                )
              else
                StickerArt(
                  color: stickerColorFor(colors, sticker.colorKind),
                  label: sticker.label,
                  shape: shapeFor(sticker.shape),
                ),
              Positioned(
                left: AppSpacing.s2,
                bottom: AppSpacing.s2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s2,
                    vertical: AppSpacing.s1,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceSolid,
                    borderRadius: AppRadius.pill,
                    border: Border.all(color: colors.line),
                  ),
                  child: Text(
                    sticker.isNew ? 'Baru' : sticker.sourceLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
