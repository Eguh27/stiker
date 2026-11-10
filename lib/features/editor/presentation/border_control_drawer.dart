import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';
import 'package:sticker_studio/core/widgets/app_slider.dart';

import 'color_palette_row.dart';

/// Panel kontrol ketebalan, feather, dan warna border (App.tsx `.border-controls`).
class BorderControlDrawer extends StatelessWidget {
  const BorderControlDrawer({
    super.key,
    required this.width,
    required this.feather,
    required this.color,
    required this.onWidthChanged,
    required this.onFeatherChanged,
    required this.onColorChanged,
  });

  final double width;
  final double feather;
  final String color;
  final ValueChanged<double> onWidthChanged;
  final ValueChanged<double> onFeatherChanged;
  final ValueChanged<String> onColorChanged;

  static const borderPalette = [
    '#ffffff',
    '#282522',
    '#e5d7ff',
    '#f4c9bb',
    '#d6ecdf',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSlider(
            label: 'Ketebalan',
            value: width,
            suffix: ' px',
            onChanged: onWidthChanged,
          ),
          AppSlider(
            label: 'Feather',
            value: feather,
            suffix: '%',
            onChanged: onFeatherChanged,
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            'Warna border',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.text2),
          ),
          const SizedBox(height: AppSpacing.s2),
          ColorPaletteRow(
            selectedColor: color,
            palette: borderPalette,
            onSelectColor: onColorChanged,
          ),
        ],
      ),
    );
  }
}
