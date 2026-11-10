import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';
import 'package:sticker_studio/core/widgets/top_bar.dart';

import '../domain/scene_layer.dart';
import '../domain/text_layer.dart';
import 'color_palette_row.dart';
import 'font_selector_row.dart';
import 'style_preset_row.dart';

/// Halaman penyunting teks stiker (App.tsx `TextEditor`).
class TextEditorPage extends StatefulWidget {
  const TextEditorPage({super.key, this.initialLayer});

  final TextLayer? initialLayer;

  @override
  State<TextEditorPage> createState() => _TextEditorPageState();
}

class _TextEditorPageState extends State<TextEditorPage> {
  late final TextEditingController _controller;
  String _font = 'Montserrat';
  String _style = 'Outline';
  String _color = '#282522';

  @override
  void initState() {
    super.initState();
    final init = widget.initialLayer;
    _controller = TextEditingController(text: init?.text ?? 'GOOD DAY!');
    if (init != null) {
      _font = init.fontFamily;
      _style = init.presetStyle;
      _color = init.color;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _parseHex(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  void _onApply() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final layer = TextLayer(
      id:
          widget.initialLayer?.id ??
          'txt-${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      fontFamily: _font,
      presetStyle: _style,
      color: _color,
      transform: widget.initialLayer?.transform ?? const LayerTransform(),
    );
    Navigator.of(context).pop(layer);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: TopBar(
        title: 'Editor Teks',
        onBack: () => Navigator.of(context).pop(),
        actions: [
          TextButton(onPressed: _onApply, child: const Text('Terapkan')),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s4),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: colors.line),
                  ),
                  child: Text(
                    _controller.text.isEmpty
                        ? 'Ketik teks...'
                        : _controller.text,
                    style: TextStyle(
                      fontFamily: _font,
                      fontSize: 36,
                      color: _parseHex(_color),
                      shadows: _style == 'Shadow'
                          ? [
                              const Shadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.s4),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border.all(color: colors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controller,
                    maxLength: 40,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Teks stiker',
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.control,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  Text('Font', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.s1),
                  FontSelectorRow(
                    selectedFont: _font,
                    onSelectFont: (f) => setState(() => _font = f),
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  Text(
                    'Preset gaya',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  StylePresetRow(
                    selectedStyle: _style,
                    onSelectStyle: (s) => setState(() => _style = s),
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  Text('Warna', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.s1),
                  ColorPaletteRow(
                    selectedColor: _color,
                    onSelectColor: (c) => setState(() => _color = c),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
