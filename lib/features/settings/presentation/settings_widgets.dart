import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass/glass_card.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';
import 'storage_usage_provider.dart';

class DarkModeRow extends StatelessWidget {
  const DarkModeRow({super.key, required this.isDark, required this.onChanged});

  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return GlassCard(blur: false, margin: const EdgeInsets.only(top: AppSpacing.s2), padding: const EdgeInsets.all(AppSpacing.s4), child: Row(
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

class StorageRow extends ConsumerWidget {
  const StorageRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> usage = ref.watch(storageUsageBytesProvider);
    final String label = usage.when(
      data: formatBytes,
      loading: () => 'Menghitung...',
      error: (_, _) => 'Tidak bisa dihitung',
    );
    return GlassCard(
      blur: false,
      margin: const EdgeInsets.only(top: AppSpacing.s2),
      padding: const EdgeInsets.all(AppSpacing.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Penyimpanan'),
          Text('$label dipakai di perangkat'),
        ],
      ),
    );
  }
}
