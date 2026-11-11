import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';

import '../domain/drawing_layer.dart';
import '../domain/scene_layer.dart';
import '../domain/scene_project.dart';
import 'brush_input_layer.dart';
import 'layer_gesture_layer.dart';
import 'scene_painter.dart';

/// Area kanvas editor dengan manipulasi layer & goresan kuas.
class EditorCanvas extends StatefulWidget {
  const EditorCanvas({
    super.key,
    required this.project,
    required this.activeLayerId,
    required this.onSelectLayer,
    required this.onTransformLayer,
    this.isBrushActive = false,
    this.brushColor = '#ff6b00',
    this.brushSize = 6.0,
    this.onAddDrawingLayer,
    this.onImagesLoaded,
  });

  final SceneProject project;
  final String? activeLayerId;
  final ValueChanged<String?> onSelectLayer;
  final void Function(String id, LayerTransform transform) onTransformLayer;
  final bool isBrushActive;
  final String brushColor;
  final double brushSize;
  final ValueChanged<DrawingLayer>? onAddDrawingLayer;
  final ValueChanged<Map<String, ui.Image>>? onImagesLoaded;

  @override
  State<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends State<EditorCanvas> {
  final Map<String, ui.Image> _imageCache = {};
  final Set<String> _loading = {};
  List<DrawingPoint> _currentStroke = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void didUpdateWidget(covariant EditorCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadImages();
  }

  Future<void> _loadImages() async {
    for (final layer in widget.project.layers) {
      if (layer is! ImageLayer) continue;
      final path = layer.imagePath;
      if (_imageCache.containsKey(path) || !_loading.add(path)) continue;
      try {
        await _decodeInto(path);
      } finally {
        _loading.remove(path);
      }
    }
  }

  Future<void> _decodeInto(String path) async {
    final file = File(path);
    if (!await file.exists()) return;
    try {
      final codec = await ui.instantiateImageCodec(await file.readAsBytes());
      final frame = await codec.getNextFrame();
      if (!mounted) {
        frame.image.dispose();
        return;
      }
      setState(() => _imageCache[path] = frame.image);
      widget.onImagesLoaded?.call(_imageCache);
    } catch (error) {
      debugPrint('Gagal memuat gambar layer $path: $error');
    }
  }

  void _endStroke() {
    if (_currentStroke.isEmpty) return;
    final double cx = widget.project.canvasWidth / 2;
    final double cy = widget.project.canvasHeight / 2;
    // Titik disimpan relatif ke pusat layer agar tidak bergeser saat dirender.
    final List<DrawingPoint> relative = [
      for (final p in _currentStroke) DrawingPoint(p.x - cx, p.y - cy),
    ];
    if (relative.length == 1) relative.add(relative.first);
    widget.onAddDrawingLayer?.call(
      DrawingLayer(
        id: 'brush-${DateTime.now().millisecondsSinceEpoch}',
        color: widget.brushColor,
        strokeWidth: widget.brushSize,
        transform: LayerTransform(x: cx, y: cy),
        points: List.unmodifiable(relative),
      ),
    );
    setState(() => _currentStroke = []);
  }

  void _addPoint(Offset point) {
    setState(() => _currentStroke = [..._currentStroke, DrawingPoint(point.dx, point.dy)]);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final SceneLayer? activeLayer = widget.project.layers
        .where((l) => l.id == widget.activeLayerId)
        .firstOrNull;

    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.s4),
          decoration: BoxDecoration(
            color: colors.glassFill,
            borderRadius: AppRadius.control,
            border: Border.all(color: colors.glassBorder),
            boxShadow: AppShadows.glass,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.control,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double factor =
                    widget.project.canvasWidth / constraints.maxWidth;
                final Widget canvas = CustomPaint(
                  painter: ScenePainter(
                    project: widget.project,
                    activeLayerId: widget.activeLayerId,
                    colors: colors,
                    images: _imageCache,
                    activeStroke: _currentStroke,
                    activeStrokeColor: widget.brushColor,
                    activeStrokeWidth: widget.brushSize,
                    showSelection: !widget.isBrushActive,
                  ),
                  child: const SizedBox.expand(),
                );
                if (widget.isBrushActive) {
                  return BrushInputLayer(
                    factor: factor,
                    onStart: (point) => setState(
                      () => _currentStroke = [DrawingPoint(point.dx, point.dy)],
                    ),
                    onMove: _addPoint,
                    onEnd: _endStroke,
                    child: canvas,
                  );
                }
                return LayerGestureLayer(
                  project: widget.project,
                  activeLayer: activeLayer,
                  images: _imageCache,
                  factor: factor,
                  onSelectLayer: widget.onSelectLayer,
                  onTransformLayer: widget.onTransformLayer,
                  child: canvas,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
