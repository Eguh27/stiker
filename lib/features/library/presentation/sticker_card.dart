import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/sticker_art.dart';
import '../domain/sticker.dart';
import 'sticker_visuals.dart';

class StickerCard extends StatelessWidget {
  const StickerCard({
    super.key,
    required this.sticker,
    this.onTap,
    this.onLongPress,
    this.selected = false,
  });

  final Sticker sticker;
  final ValueChanged<Sticker>? onTap;
  final ValueChanged<Sticker>? onLongPress;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Material(
      color: colors.glassFill,
      borderRadius: AppRadius.card,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: onTap == null ? null : () => onTap!(sticker),
        onLongPress: onLongPress == null ? null : () => onLongPress!(sticker),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            border: Border.all(
              color: selected ? colors.accent : colors.glassBorder,
              width: selected ? 2.5 : 1,
            ),
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
              if (selected)
                Positioned(
                  top: AppSpacing.s2,
                  right: AppSpacing.s2,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: colors.accent,
                    child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                  ),
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
