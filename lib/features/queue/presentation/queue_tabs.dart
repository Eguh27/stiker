import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Tab Dalam proses / Baru Diimpor (Inbox) untuk Queue Monitor.
class QueueTabs extends StatelessWidget {
  const QueueTabs({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.activeCount,
    required this.doneCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int activeCount;
  final int doneCount;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s1),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Dalam proses $activeCount',
            selected: selectedIndex == 0,
            onTap: () => onSelected(0),
            colors: colors,
          ),
          _Tab(
            label: 'Baru Diimpor $doneCount',
            selected: selectedIndex == 1,
            onTap: () => onSelected(1),
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? colors.surfaceSolid : colors.surfaceMuted,
        borderRadius: AppRadius.pill,
        child: InkWell(
          borderRadius: AppRadius.pill,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppLayout.segmentedMinHeight,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? colors.text : colors.text2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
