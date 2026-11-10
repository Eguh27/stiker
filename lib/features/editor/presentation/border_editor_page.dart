import 'package:flutter/material.dart';
import 'package:sticker_studio/core/widgets/top_bar.dart';

import 'border_control_drawer.dart';
import 'border_preview_canvas.dart';

/// Halaman penyunting border stiker (App.tsx `BorderEditor`).
class BorderEditorPage extends StatefulWidget {
  const BorderEditorPage({
    super.key,
    this.initialWidth = 12.0,
    this.initialFeather = 8.0,
    this.initialColor = '#ffffff',
  });

  final double initialWidth;
  final double initialFeather;
  final String initialColor;

  @override
  State<BorderEditorPage> createState() => _BorderEditorPageState();
}

class _BorderEditorPageState extends State<BorderEditorPage> {
  late double _width;
  late double _feather;
  late String _color;

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
    _feather = widget.initialFeather;
    _color = widget.initialColor;
  }

  Color _parseHex(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  void _onApply() {
    Navigator.of(context)
        .pop({'width': _width, 'feather': _feather, 'color': _color});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        title: 'Border Stiker',
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
              child: BorderPreviewCanvas(
                width: _width,
                feather: _feather,
                color: _parseHex(_color),
              ),
            ),
            BorderControlDrawer(
              width: _width,
              feather: _feather,
              color: _color,
              onWidthChanged: (v) => setState(() => _width = v),
              onFeatherChanged: (v) => setState(() => _feather = v),
              onColorChanged: (c) => setState(() => _color = c),
            ),
          ],
        ),
      ),
    );
  }
}
