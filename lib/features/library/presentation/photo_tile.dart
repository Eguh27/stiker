import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/sticker_art.dart';
import '../domain/sticker.dart';
import 'sticker_visuals.dart';

class PhotoTile extends StatelessWidget {
  const PhotoTile({
    super.key,
    required this.photo,
    required this.isSelected,
    required this.onTap,
  });

  final Sticker photo;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Material(
      color: colors.surfaceMuted,
      borderRadius: AppRadius.control,
      child: InkWell(
        borderRadius: AppRadius.control,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.control,
            border: isSelected
                ? Border.all(color: colors.accent, width: 3)
                : Border.all(color: colors.line),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              StickerArt(
                color: stickerColorFor(colors, photo.colorKind),
                label: photo.label,
                shape: shapeFor(photo.shape),
              ),
              Positioned(
                top: AppSpacing.s1,
                right: AppSpacing.s1,
                child: Container(
                  width: AppLayout.iconGridSize,
                  height: AppLayout.iconGridSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? colors.accent : colors.lineStrong,
                  ),
                  child: isSelected
                      ? AppIcon(
                          AppIconName.check,
                          size: 15,
                          color: colors.accentText,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
