import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../domain/scene_layer.dart';
import '../domain/scene_project.dart';
import 'layer_bounds.dart';

/// Gestur pilih (tap), geser, cubit-skala, dan putar untuk layer aktif.
class LayerGestureLayer extends StatefulWidget {
  const LayerGestureLayer({
    super.key,
    required this.project,
    required this.activeLayer,
    required this.images,
    required this.factor,
    required this.onSelectLayer,
    required this.onTransformLayer,
    required this.child,
  });

  final SceneProject project;
  final SceneLayer? activeLayer;
  final Map<String, ui.Image> images;
  final double factor;
  final ValueChanged<String?> onSelectLayer;
  final void Function(String id, LayerTransform transform) onTransformLayer;
  final Widget child;

  @override
  State<LayerGestureLayer> createState() => _LayerGestureLayerState();
}

class _LayerGestureLayerState extends State<LayerGestureLayer> {
  Offset _startFocal = Offset.zero;
  LayerTransform _startTransform = const LayerTransform();

  void _select(Offset canvasPoint) {
    for (final SceneLayer layer in widget.project.layers.reversed) {
      if (layer.visible && hitLayer(layer, canvasPoint, widget.images)) {
        widget.onSelectLayer(layer.id);
        return;
      }
    }
    widget.onSelectLayer(null);
  }

  void _update(ScaleUpdateDetails details) {
    final SceneLayer? layer = widget.activeLayer;
    if (layer == null) return;
    final Offset delta = details.localFocalPoint - _startFocal;
    widget.onTransformLayer(
      layer.id,
      _startTransform.copyWith(
        x: _startTransform.x + delta.dx * widget.factor,
        y: _startTransform.y + delta.dy * widget.factor,
        scale: (_startTransform.scale * details.scale).clamp(0.2, 5.0),
        rotation: _startTransform.rotation + details.rotation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) => _select(details.localPosition * widget.factor),
      onScaleStart: (details) {
        _startFocal = details.localFocalPoint;
        _startTransform = widget.activeLayer?.transform ?? const LayerTransform();
      },
      onScaleUpdate: _update,
      child: widget.child,
    );
  }
}
