import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/editor/domain/drawing_layer.dart';
import 'package:sticker_studio/features/editor/domain/scene_layer.dart';
import 'package:sticker_studio/features/editor/presentation/layer_bounds.dart';

void main() {
  const stroke = DrawingLayer(
    id: 'brush-1',
    strokeWidth: 8,
    transform: LayerTransform(x: 256, y: 256),
    points: [DrawingPoint(-40, -20), DrawingPoint(40, 20)],
  );

  test('bounds coretan mengikuti titik relatif + setengah lebar kuas', () {
    expect(layerBounds(stroke, const {}), const Rect.fromLTRB(-44, -24, 44, 24));
  });

  test('hitLayer mengenai coretan di posisi layer, bukan di sudut kanvas', () {
    expect(hitLayer(stroke, const Offset(256, 256), const {}), isTrue);
    expect(hitLayer(stroke, const Offset(20, 20), const {}), isFalse);
  });

  test('hitLayer memperhitungkan rotasi layer', () {
    final rotated = DrawingLayer(
      id: 'brush-2',
      strokeWidth: 4,
      transform: const LayerTransform(x: 100, y: 100, rotation: 1.5707963),
      points: const [DrawingPoint(-60, 0), DrawingPoint(60, 0)],
    );
    expect(hitLayer(rotated, const Offset(100, 150), const {}), isTrue);
    expect(hitLayer(rotated, const Offset(160, 100), const {}), isFalse);
  });
}
