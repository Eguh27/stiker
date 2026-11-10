import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';
import 'package:sticker_studio/core/widgets/app_slider.dart';
import 'package:sticker_studio/core/widgets/top_bar.dart';

import 'brush_mode_toggle.dart';
import 'remove_background_canvas.dart';

/// Halaman hapus background manual dengan kuas (App.tsx `RemoveBackground`).
class RemoveBackgroundPage extends StatefulWidget {
  const RemoveBackgroundPage({
    super.key,
    this.initialSize = 42.0,
    this.initialFeather = 18.0,
  });

  final double initialSize;
  final double initialFeather;

  @override
  State<RemoveBackgroundPage> createState() => _RemoveBackgroundPageState();
}

class _RemoveBackgroundPageState extends State<RemoveBackgroundPage> {
  String _mode = 'Erase';
  late double _size;
  late double _feather;

  @override
  void initState() {
    super.initState();
    _size = widget.initialSize;
    _feather = widget.initialFeather;
  }

  void _onApply() {
    Navigator.of(context)
        .pop({'mode': _mode, 'size': _size, 'feather': _feather});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: TopBar(
        title: 'Hapus Background',
        onBack: () => Navigator.of(context).pop(),
        actions: [
          TextButton(onPressed: _onApply, child: const Text('Terapkan')),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(child: RemoveBackgroundCanvas(brushSize: _size)),
            Container(
              padding: const EdgeInsets.all(AppSpacing.s4),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.line)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BrushModeToggle(
                    mode: _mode,
                    onSelect: (m) => setState(() => _mode = m),
                  ),
                  AppSlider(
                    label: 'Ukuran kuas',
                    value: _size,
                    suffix: ' px',
                    min: 5,
                    max: 100,
                    onChanged: (v) => setState(() => _size = v),
                  ),
                  AppSlider(
                    label: 'Feather',
                    value: _feather,
                    suffix: '%',
                    onChanged: (v) => setState(() => _feather = v),
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
