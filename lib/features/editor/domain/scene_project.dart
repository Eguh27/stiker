import 'drawing_layer.dart';
import 'scene_layer.dart';
import 'text_layer.dart';

/// Model kanvas project editor stiker (ukuran baku 512×512 px).
class SceneProject {
  const SceneProject({
    this.version = 1,
    this.canvasWidth = 512.0,
    this.canvasHeight = 512.0,
    this.layers = const [],
  });

  factory SceneProject.fromJson(Map<String, dynamic> json) {
    final canvas = json['canvas'] is Map<String, dynamic>
        ? json['canvas'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final rawLayers = json['layers'] as List? ?? const [];

    final layers = <SceneLayer>[];
    for (final raw in rawLayers) {
      if (raw is Map<String, dynamic>) {
        final type = raw['type'] as String?;
        if (type == 'image') {
          layers.add(ImageLayer.fromJson(raw));
        } else if (type == 'text') {
          layers.add(TextLayer.fromJson(raw));
        } else if (type == 'drawing') {
          layers.add(DrawingLayer.fromJson(raw));
        }
      }
    }

    return SceneProject(
      version: json['version'] as int? ?? 1,
      canvasWidth: (canvas['width'] as num?)?.toDouble() ?? 512.0,
      canvasHeight: (canvas['height'] as num?)?.toDouble() ?? 512.0,
      layers: List.unmodifiable(layers),
    );
  }

  final int version;
  final double canvasWidth;
  final double canvasHeight;
  final List<SceneLayer> layers;

  SceneProject copyWith({
    int? version,
    double? canvasWidth,
    double? canvasHeight,
    List<SceneLayer>? layers,
  }) {
    return SceneProject(
      version: version ?? this.version,
      canvasWidth: canvasWidth ?? this.canvasWidth,
      canvasHeight: canvasHeight ?? this.canvasHeight,
      layers: layers != null ? List.unmodifiable(layers) : this.layers,
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'canvas': {'width': canvasWidth, 'height': canvasHeight},
    'layers': [for (final layer in layers) layer.toJson()],
  };
}
