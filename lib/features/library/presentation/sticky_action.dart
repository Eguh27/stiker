import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon.dart';

class StickyAction extends StatelessWidget {
  const StickyAction({
    super.key,
    required this.selectedCount,
    required this.onImport,
  });

  final int selectedCount;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s5,
        AppSpacing.s3,
        AppSpacing.s5,
        AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceSolid,
        border: Border(top: BorderSide(color: colors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$selectedCount file',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
                Text(
                  'PNG · JPG · WEBP',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: selectedCount == 0 ? null : onImport,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Import'),
                SizedBox(width: AppSpacing.s2),
                AppIcon(AppIconName.download, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
