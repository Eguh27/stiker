import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Segmented Semua / Inbox dari App.tsx (dinamis per DB).
class LibrarySegmented extends StatelessWidget {
  const LibrarySegmented({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.allCount,
    this.newCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int? allCount;
  final int? newCount;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final int all = allCount ?? 48;
    final int inbox = newCount ?? 8;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s1),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        children: [
          _Segment(
            label: 'Semua $all',
            selected: selectedIndex == 0,
            onTap: () => onSelected(0),
            colors: colors,
          ),
          _Segment(
            label: 'Inbox / Baru $inbox',
            selected: selectedIndex == 1,
            onTap: () => onSelected(1),
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
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
