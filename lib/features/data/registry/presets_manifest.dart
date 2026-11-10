import 'manifest_json.dart';

class PresetsManifest {
  const PresetsManifest({required this.version, required this.presets});

  factory PresetsManifest.fromJson(
    Map<String, dynamic> json, {
    required String source,
  }) {
    final reader = ManifestJson(json, source: source);
    final version = reader.version;
    final entries = reader.list(json['presets'], 'presets');
    final presets = <PresetDefinition>[];

    for (final (index, entry) in entries.indexed) {
      final path = 'presets[$index]';
      final map = reader.object(entry, path);
      presets.add(
        PresetDefinition(
          id: reader.string(map['id'], '$path.id'),
          name: reader.string(map['name'], '$path.name'),
          stroke: Map.unmodifiable(
            reader.object(map['stroke'], '$path.stroke'),
          ),
          shadow: Map.unmodifiable(
            reader.object(map['shadow'], '$path.shadow'),
          ),
          background: Map.unmodifiable(
            reader.object(map['background'], '$path.background'),
          ),
        ),
      );
    }

    return PresetsManifest(
      version: version,
      presets: List.unmodifiable(presets),
    );
  }

  final int version;
  final List<PresetDefinition> presets;
}

class PresetDefinition {
  const PresetDefinition({
    required this.id,
    required this.name,
    required this.stroke,
    required this.shadow,
    required this.background,
  });

  final String id;
  final String name;
  final Map<String, dynamic> stroke;
  final Map<String, dynamic> shadow;
  final Map<String, dynamic> background;
}
