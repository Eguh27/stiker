import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass/glass_card.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';

/// ToggleCard Auto-RMBG (screen-map queue).
class AutoRmbgToggleCard extends StatelessWidget {
  const AutoRmbgToggleCard({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return GlassCard(blur: false, padding: const EdgeInsets.all(AppSpacing.s4), child: Row(
        children: [
          Container(
            width: AppLayout.iconButtonSize,
            height: AppLayout.iconButtonSize,
            decoration: BoxDecoration(
              color: colors.accentSoft,
              borderRadius: AppRadius.control,
            ),
            child: AppIcon(AppIconName.brush, color: colors.accent),
          ),
          const SizedBox(width: AppSpacing.s3),
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Auto-RMBG'), Text('Hapus latar saat impor')],
            ),
          ),
          Switch(value: enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}
