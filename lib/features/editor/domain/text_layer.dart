import 'scene_layer.dart';

/// Layer teks pada scene graph dengan styling (font, preset, color).
class TextLayer extends SceneLayer {
  const TextLayer({
    required super.id,
    super.visible,
    super.transform,
    required this.text,
    this.fontFamily = 'Montserrat',
    this.fontSize = 36.0,
    this.color = '#282522',
    this.presetStyle = 'None',
    this.styleColor = '#FFFFFF',
  });

  factory TextLayer.fromJson(Map<String, dynamic> json) {
    return TextLayer(
      id: json['id'] as String,
      visible: json['visible'] as bool? ?? true,
      transform: json['transform'] is Map<String, dynamic>
          ? LayerTransform.fromJson(json['transform'] as Map<String, dynamic>)
          : const LayerTransform(),
      text: json['text'] as String? ?? '',
      fontFamily: json['font_family'] as String? ?? 'Montserrat',
      fontSize: (json['font_size'] as num?)?.toDouble() ?? 36.0,
      color: json['color'] as String? ?? '#282522',
      presetStyle: json['preset_style'] as String? ?? 'None',
      styleColor: json['style_color'] as String? ?? '#FFFFFF',
    );
  }

  final String text;
  final String fontFamily;
  final double fontSize;
  final String color;
  final String presetStyle;
  final String styleColor;

  TextLayer copyWith({
    String? text,
    String? fontFamily,
    double? fontSize,
    String? color,
    String? presetStyle,
    String? styleColor,
    LayerTransform? transform,
    bool? visible,
  }) {
    return TextLayer(
      id: id,
      visible: visible ?? this.visible,
      transform: transform ?? this.transform,
      text: text ?? this.text,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      presetStyle: presetStyle ?? this.presetStyle,
      styleColor: styleColor ?? this.styleColor,
    );
  }

  @override
  TextLayer copyWithTransform(LayerTransform transform) =>
      copyWith(transform: transform);

  @override
  TextLayer copyWithVisibility(bool visible) => copyWith(visible: visible);

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'text',
    'visible': visible,
    'transform': transform.toJson(),
    'text': text,
    'font_family': fontFamily,
    'font_size': fontSize,
    'color': color,
    'preset_style': presetStyle,
    'style_color': styleColor,
  };
}
