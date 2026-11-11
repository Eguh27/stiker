import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Toggle kapsul: wadah kaca, segmen aktif putih solid bertulisan gelap.
class GlassSegmented<T> extends StatelessWidget {
  const GlassSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  /// Urutan tampil mengikuti urutan entri map.
  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s1),
      decoration: BoxDecoration(
        color: c.glassFill,
        borderRadius: AppRadius.pill,
        border: Border.all(color: c.glassBorder),
      ),
      child: Row(
        children: [
          for (final MapEntry<T, String> entry in options.entries)
            Expanded(child: _segment(context, c, entry)),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, AppColors c, MapEntry<T, String> entry) {
    final bool selected = entry.key == value;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: AppRadius.pill,
      ),
      child: InkWell(
        borderRadius: AppRadius.pill,
        onTap: () => onChanged(entry.key),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppLayout.segmentedMinHeight),
          alignment: Alignment.center,
          child: Text(
            entry.value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? Colors.black87 : c.text2,
            ),
          ),
        ),
      ),
    );
  }
}
