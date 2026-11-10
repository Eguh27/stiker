import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';
import 'package:sticker_studio/core/widgets/app_icon.dart';

/// Tombol toggle mode kuas (Erase / Restore) (App.tsx `.mode-toggle`).
class BrushModeToggle extends StatelessWidget {
  const BrushModeToggle({
    super.key,
    required this.mode,
    required this.onSelect,
  });

  final String mode;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(child: _btn(context, 'Erase', AppIconName.close, colors)),
        const SizedBox(width: AppSpacing.s2),
        Expanded(child: _btn(context, 'Restore', AppIconName.brush, colors)),
      ],
    );
  }

  Widget _btn(
    BuildContext context,
    String label,
    AppIconName icon,
    AppColors colors,
  ) {
    final active = mode == label;
    return ElevatedButton.icon(
      onPressed: () => onSelect(label),
      icon: AppIcon(
        icon,
        size: 16,
        color: active ? Colors.white : colors.text2,
      ),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? colors.accent : colors.surface,
        foregroundColor: active ? Colors.white : colors.text,
        elevation: active ? 2 : 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.control),
        side: BorderSide(color: active ? colors.accent : colors.line),
      ),
    );
  }
}
