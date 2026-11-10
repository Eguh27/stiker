import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';

/// Palet warna cepat untuk kuas stiker.
class BrushPalette extends StatelessWidget {
  const BrushPalette({
    super.key,
    required this.selectedColor,
    required this.onSelectColor,
  });

  final String selectedColor;
  final ValueChanged<String> onSelectColor;

  static const List<String> colors = [
    '#ff6b00',
    '#ffffff',
    '#000000',
    '#ef4444',
    '#3b82f6',
    '#22c55e',
    '#eab308',
    '#a855f7',
  ];

  Color _parse(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s2,
      ),
      color: appColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final c in colors)
            GestureDetector(
              onTap: () => onSelectColor(c),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _parse(c),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selectedColor == c
                        ? appColors.accent
                        : appColors.line,
                    width: selectedColor == c ? 3 : 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
