import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';
import '../domain/pack_limits.dart';

/// Kartu validasi 3–30 stiker (App.tsx `validation-card`): hijau bila ok.
class PackValidationCard extends StatelessWidget {
  const PackValidationCard({super.key, required this.stickerCount});

  final int stickerCount;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final bool hasMin = stickerCount >= PackLimits.minStickers;
    final bool withinMax = stickerCount <= PackLimits.maxStickers;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.control,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Rule(
            colors: colors,
            ok: hasMin,
            label: 'Minimal ${PackLimits.minStickers} stiker',
          ),
          _Rule(
            colors: colors,
            ok: withinMax,
            label: 'Maksimal ${PackLimits.maxStickers} stiker',
          ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.colors, required this.ok, required this.label});

  final AppColors colors;
  final bool ok;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Color tone = ok ? colors.success : colors.danger;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(
          ok ? AppIconName.check : AppIconName.close,
          size: AppLayout.validationIconSize,
          color: tone,
        ),
        const SizedBox(width: AppSpacing.s1),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: tone),
        ),
      ],
    );
  }
}
