import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';

class PrivacyNote extends StatelessWidget {
  const PrivacyNote({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.line),
      ),
      child: Row(
        children: [
          AppIcon(AppIconName.cloud, color: colors.accent),
          const SizedBox(width: AppSpacing.s3),
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tetap privat'),
                Text(
                  'Tidak ada gambar yang dikirim ke cloud. '
                  'Semua proses berjalan di perangkat ini.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
