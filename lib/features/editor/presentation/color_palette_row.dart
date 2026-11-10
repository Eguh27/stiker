import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';

/// Baris pemilih warna teks (App.tsx `color-row`).
class ColorPaletteRow extends StatelessWidget {
  const ColorPaletteRow({
    super.key,
    required this.selectedColor,
    required this.onSelectColor,
    this.palette = defaultPalette,
  });

  final String selectedColor;
  final ValueChanged<String> onSelectColor;
  final List<String> palette;

  static const List<String> defaultPalette = [
    '#282522',
    '#ffffff',
    '#8d7bd6',
    '#dc8e78',
    '#e6c65a',
    '#78a78b',
  ];

  @override
  Widget build(BuildContext context) {
    Color parseHex(String hex) {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final hex in palette)
            GestureDetector(
              onTap: () => onSelectColor(hex),
              child: Container(
                margin: const EdgeInsets.only(right: AppSpacing.s2),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: parseHex(hex),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selectedColor == hex
                        ? Colors.blue
                        : Colors.grey.shade400,
                    width: selectedColor == hex ? 3 : 1,
                  ),
                ),
                child: selectedColor == hex
                    ? Icon(
                        Icons.check,
                        size: 18,
                        color: hex == '#ffffff' ? Colors.black : Colors.white,
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
