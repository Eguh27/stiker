/// Transformasi geometri untuk satu layer di kanvas 512×512.
class LayerTransform {
  const LayerTransform({
    this.x = 256.0,
    this.y = 256.0,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  factory LayerTransform.fromJson(Map<String, dynamic> json) {
    return LayerTransform(
      x: (json['x'] as num?)?.toDouble() ?? 256.0,
      y: (json['y'] as num?)?.toDouble() ?? 256.0,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final double x;
  final double y;
  final double scale;
  final double rotation;

  LayerTransform copyWith({
    double? x,
    double? y,
    double? scale,
    double? rotation,
  }) {
    return LayerTransform(
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'scale': scale,
    'rotation': rotation,
  };
}

/// Base class untuk layer di scene graph editor stiker.
abstract class SceneLayer {
  const SceneLayer({
    required this.id,
    this.visible = true,
    this.transform = const LayerTransform(),
  });

  final String id;
  final bool visible;
  final LayerTransform transform;

  SceneLayer copyWithTransform(LayerTransform transform);
  SceneLayer copyWithVisibility(bool visible);
  Map<String, dynamic> toJson();
}

/// Layer stiker gambar / asset.
class ImageLayer extends SceneLayer {
  const ImageLayer({
    required super.id,
    super.visible,
    super.transform,
    required this.imagePath,
    this.stickerId,
  });

  factory ImageLayer.fromJson(Map<String, dynamic> json) {
    return ImageLayer(
      id: json['id'] as String,
      visible: json['visible'] as bool? ?? true,
      transform: json['transform'] is Map<String, dynamic>
          ? LayerTransform.fromJson(json['transform'] as Map<String, dynamic>)
          : const LayerTransform(),
      imagePath: json['image_path'] as String? ?? '',
      stickerId: json['sticker_id'] as String?,
    );
  }

  final String imagePath;
  final String? stickerId;

  @override
  ImageLayer copyWithTransform(LayerTransform transform) {
    return ImageLayer(
      id: id,
      visible: visible,
      transform: transform,
      imagePath: imagePath,
      stickerId: stickerId,
    );
  }

  @override
  ImageLayer copyWithVisibility(bool visible) {
    return ImageLayer(
      id: id,
      visible: visible,
      transform: transform,
      imagePath: imagePath,
      stickerId: stickerId,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'image',
    'visible': visible,
    'transform': transform.toJson(),
    'image_path': imagePath,
    if (stickerId != null) 'sticker_id': stickerId,
  };
}
