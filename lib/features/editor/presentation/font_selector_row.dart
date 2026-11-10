import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';

/// Baris pemilih font terdaftar di fonts_manifest (App.tsx `font-row`).
class FontSelectorRow extends StatelessWidget {
  const FontSelectorRow({
    super.key,
    required this.selectedFont,
    required this.onSelectFont,
  });

  final String selectedFont;
  final ValueChanged<String> onSelectFont;

  static const List<String> availableFonts = ['Montserrat', 'Inter', 'Serif'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final font in availableFonts)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.s2),
              child: ChoiceChip(
                selected: selectedFont == font,
                label: Text(font),
                onSelected: (_) => onSelectFont(font),
                selectedColor: colors.accentSoft,
                backgroundColor: colors.surface,
                side: BorderSide(
                  color: selectedFont == font ? colors.accent : colors.line,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
