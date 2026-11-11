import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../domain/drawing_layer.dart';
import '../domain/scene_layer.dart';
import '../domain/text_layer.dart';

const double _imageBox = 440;
const double _fallbackBox = 220;

/// Ukuran target gambar di kanvas (sisi terpanjang 440 px, rasio dijaga).
Size imageTargetSize(ui.Image image) {
  final double aspect = image.width / (image.height == 0 ? 1 : image.height);
  return aspect >= 1
      ? Size(_imageBox, _imageBox / aspect)
      : Size(_imageBox * aspect, _imageBox);
}

TextPainter layoutText(TextLayer layer, [Color? color]) {
  return TextPainter(
    text: TextSpan(
      text: layer.text,
      style: TextStyle(
        fontSize: layer.fontSize,
        fontFamily: layer.fontFamily,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}

/// Kotak pembatas layer di ruang lokalnya (pusat layer = titik 0,0).
Rect layerBounds(SceneLayer layer, Map<String, ui.Image> images) {
  if (layer is ImageLayer) {
    final ui.Image? image = images[layer.imagePath];
    final Size size = image == null
        ? const Size(_fallbackBox, _fallbackBox)
        : imageTargetSize(image);
    return Rect.fromCenter(center: Offset.zero, width: size.width, height: size.height);
  }
  if (layer is TextLayer) {
    final TextPainter painter = layoutText(layer);
    return Rect.fromCenter(
      center: Offset.zero,
      width: painter.width,
      height: painter.height,
    );
  }
  if (layer is DrawingLayer && layer.points.isNotEmpty) {
    return _strokeBounds(layer);
  }
  return Rect.fromCenter(center: Offset.zero, width: 240, height: 240);
}

Rect _strokeBounds(DrawingLayer layer) {
  var minX = double.infinity, minY = double.infinity;
  var maxX = -double.infinity, maxY = -double.infinity;
  for (final DrawingPoint p in layer.points) {
    minX = math.min(minX, p.x);
    minY = math.min(minY, p.y);
    maxX = math.max(maxX, p.x);
    maxY = math.max(maxY, p.y);
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY).inflate(layer.strokeWidth / 2);
}

/// Apakah titik kanvas [point] mengenai [layer] (memperhitungkan rotasi/skala).
bool hitLayer(SceneLayer layer, Offset point, Map<String, ui.Image> images) {
  final LayerTransform t = layer.transform;
  final Offset shifted = point - Offset(t.x, t.y);
  final double cos = math.cos(-t.rotation), sin = math.sin(-t.rotation);
  final Offset local = Offset(
    (shifted.dx * cos - shifted.dy * sin) / t.scale,
    (shifted.dx * sin + shifted.dy * cos) / t.scale,
  );
  return layerBounds(layer, images).inflate(12 / t.scale).contains(local);
}
