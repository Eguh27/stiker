import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';

class DarkModeRow extends StatelessWidget {
  const DarkModeRow({super.key, required this.isDark, required this.onChanged});

  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.s2),
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.line),
      ),
      child: Row(
        children: [
          AppIcon(
            isDark ? AppIconName.moon : AppIconName.sun,
            color: colors.accent,
          ),
          const SizedBox(width: AppSpacing.s3),
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Mode gelap'), Text('Soft reverse theme')],
            ),
          ),
          Switch(value: isDark, onChanged: onChanged),
        ],
      ),
    );
  }
}

class StorageRow extends StatelessWidget {
  const StorageRow({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.s2),
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Penyimpanan'),
          const Text('428 MB / 2 GB'),
          const SizedBox(height: AppSpacing.s2),
          LinearProgressIndicator(
            value: 0.21,
            backgroundColor: colors.surfaceMuted,
            color: colors.accent,
          ),
        ],
      ),
    );
  }
}
