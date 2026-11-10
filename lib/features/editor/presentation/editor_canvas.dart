import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';

import '../domain/drawing_layer.dart';
import '../domain/scene_layer.dart';
import '../domain/scene_project.dart';
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
  });

  final SceneProject project;
  final String? activeLayerId;
  final ValueChanged<String?> onSelectLayer;
  final void Function(String id, LayerTransform transform) onTransformLayer;
  final bool isBrushActive;
  final String brushColor;
  final double brushSize;
  final ValueChanged<DrawingLayer>? onAddDrawingLayer;

  @override
  State<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends State<EditorCanvas> {
  Offset _startFocal = Offset.zero;
  LayerTransform _startTransform = const LayerTransform();
  final Map<String, ui.Image> _imageCache = {};
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
      if (layer is ImageLayer && !_imageCache.containsKey(layer.imagePath)) {
        final file = File(layer.imagePath);
        if (await file.exists()) {
          try {
            final bytes = await file.readAsBytes();
            final codec = await ui.instantiateImageCodec(bytes);
            final frame = await codec.getNextFrame();
            if (mounted) {
              setState(() => _imageCache[layer.imagePath] = frame.image);
            }
          } catch (_) {}
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeLayer = widget.project.layers
        .where((l) => l.id == widget.activeLayerId)
        .firstOrNull;

    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.s4),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.card,
            border: Border.all(color: colors.line),
            boxShadow: AppShadows.card,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.card,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final side = constraints.maxWidth;
                final factor = widget.project.canvasWidth / side;

                return GestureDetector(
                  onScaleStart: (details) {
                    if (widget.isBrushActive) {
                      final pt = details.localFocalPoint * factor;
                      setState(() {
                        _currentStroke = [DrawingPoint(pt.dx, pt.dy)];
                      });
                    } else if (activeLayer != null) {
                      _startFocal = details.localFocalPoint;
                      _startTransform = activeLayer.transform;
                    }
                  },
                  onScaleUpdate: (details) {
                    if (widget.isBrushActive) {
                      final pt = details.localFocalPoint * factor;
                      setState(() {
                        _currentStroke.add(DrawingPoint(pt.dx, pt.dy));
                      });
                    } else if (activeLayer != null) {
                      final delta = details.localFocalPoint - _startFocal;
                      final next = _startTransform.copyWith(
                        x: _startTransform.x + delta.dx,
                        y: _startTransform.y + delta.dy,
                        scale: (_startTransform.scale * details.scale).clamp(
                          0.2,
                          5.0,
                        ),
                        rotation: _startTransform.rotation + details.rotation,
                      );
                      widget.onTransformLayer(activeLayer.id, next);
                    }
                  },
                  onScaleEnd: (details) {
                    if (widget.isBrushActive && _currentStroke.isNotEmpty) {
                      final stroke = DrawingLayer(
                        id: 'brush-${DateTime.now().millisecondsSinceEpoch}',
                        color: widget.brushColor,
                        strokeWidth: widget.brushSize,
                        points: List.unmodifiable(_currentStroke),
                      );
                      widget.onAddDrawingLayer?.call(stroke);
                      setState(() => _currentStroke = []);
                    }
                  },
                  child: CustomPaint(
                    painter: ScenePainter(
                      project: widget.project,
                      activeLayerId: widget.activeLayerId,
                      colors: colors,
                      images: _imageCache,
                      activeStroke: _currentStroke,
                      activeStrokeColor: widget.brushColor,
                      activeStrokeWidth: widget.brushSize,
                    ),
                    child: const SizedBox.expand(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
