import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';

/// Sel tombol tambah stiker di grid editor (App.tsx `add-sticker`).
class PackAddStickerCell extends StatelessWidget {
  const PackAddStickerCell({super.key, required this.canAdd, this.onAdd});

  final bool canAdd;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final Color contentColor = canAdd ? colors.text2 : colors.text3;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.control,
        border: Border.all(
          color: canAdd ? colors.line : colors.line.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.control,
          onTap: canAdd ? onAdd : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(AppIconName.plus, color: contentColor),
              const SizedBox(height: AppSpacing.s1),
              Text(
                'Tambah',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: contentColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
