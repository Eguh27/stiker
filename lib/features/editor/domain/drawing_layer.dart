import 'scene_layer.dart';

/// Titik koordinat goresan kuas.
class DrawingPoint {
  const DrawingPoint(this.x, this.y);

  factory DrawingPoint.fromJson(List<dynamic> json) =>
      DrawingPoint((json[0] as num).toDouble(), (json[1] as num).toDouble());

  final double x;
  final double y;

  List<double> toJson() => [x, y];
}

/// Layer goresan kuas (brush / doodle) di atas stiker.
class DrawingLayer extends SceneLayer {
  const DrawingLayer({
    required super.id,
    super.visible,
    super.transform,
    this.color = '#ff6b00',
    this.strokeWidth = 6.0,
    this.points = const [],
  });

  factory DrawingLayer.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'] as List? ?? const [];
    return DrawingLayer(
      id: json['id'] as String,
      visible: json['visible'] as bool? ?? true,
      transform: json['transform'] is Map<String, dynamic>
          ? LayerTransform.fromJson(json['transform'] as Map<String, dynamic>)
          : const LayerTransform(),
      color: json['color'] as String? ?? '#ff6b00',
      strokeWidth: (json['stroke_width'] as num?)?.toDouble() ?? 6.0,
      points: [
        for (final p in rawPoints)
          if (p is List && p.length >= 2) DrawingPoint.fromJson(p),
      ],
    );
  }

  final String color;
  final double strokeWidth;
  final List<DrawingPoint> points;

  @override
  DrawingLayer copyWithTransform(LayerTransform transform) => DrawingLayer(
    id: id,
    visible: visible,
    transform: transform,
    color: color,
    strokeWidth: strokeWidth,
    points: points,
  );

  @override
  DrawingLayer copyWithVisibility(bool visible) => DrawingLayer(
    id: id,
    visible: visible,
    transform: transform,
    color: color,
    strokeWidth: strokeWidth,
    points: points,
  );

  DrawingLayer copyWithPoints(List<DrawingPoint> points) => DrawingLayer(
    id: id,
    visible: visible,
    transform: transform,
    color: color,
    strokeWidth: strokeWidth,
    points: points,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'drawing',
    'visible': visible,
    'transform': transform.toJson(),
    'color': color,
    'stroke_width': strokeWidth,
    'points': [for (final p in points) p.toJson()],
  };
}
