import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/glass/glass_card.dart';
import '../../../core/widgets/glass/glass_pill_button.dart';

/// Bilah aksi mode seleksi: jumlah terpilih, Batal, dan Hapus.
class SelectionBar extends StatelessWidget {
  const SelectionBar({
    super.key,
    required this.count,
    required this.onCancel,
    required this.onDelete,
  });

  final int count;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: AppRadius.pill,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count dipilih',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: AppSpacing.s4),
          GlassPillButton(label: 'Batal', onPressed: onCancel),
          const SizedBox(width: AppSpacing.s2),
          GlassPillButton(
            label: 'Hapus',
            style: GlassPillStyle.accent,
            icon: const AppIcon(AppIconName.delete, size: 18, color: Colors.white),
            onPressed: count == 0 ? null : onDelete,
          ),
        ],
      ),
    );
  }
}
