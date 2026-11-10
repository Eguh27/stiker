import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';

/// Baris pemilih preset gaya teks (App.tsx `style-row`).
class StylePresetRow extends StatelessWidget {
  const StylePresetRow({
    super.key,
    required this.selectedStyle,
    required this.onSelectStyle,
  });

  final String selectedStyle;
  final ValueChanged<String> onSelectStyle;

  static const List<String> availableStyles = [
    'None',
    'Outline',
    'Shadow',
    'Latar',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final style in availableStyles)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.s2),
              child: ChoiceChip(
                selected: selectedStyle == style,
                label: Text(style),
                onSelected: (_) => onSelectStyle(style),
                selectedColor: colors.accentSoft,
                backgroundColor: colors.surface,
                side: BorderSide(
                  color: selectedStyle == style ? colors.accent : colors.line,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
