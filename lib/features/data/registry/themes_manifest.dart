import 'manifest_json.dart';

class ThemesManifest {
  const ThemesManifest({required this.version, required this.themes});

  factory ThemesManifest.fromJson(
    Map<String, dynamic> json, {
    required String source,
  }) {
    final reader = ManifestJson(json, source: source);
    final version = reader.version;
    final entries = reader.list(json['themes'], 'themes');
    final themes = <ThemeDefinition>[];

    for (final (index, entry) in entries.indexed) {
      final path = 'themes[$index]';
      final map = reader.object(entry, path);
      final tokens = reader.object(map['tokens'], '$path.tokens');
      if (tokens.isEmpty) {
        reader.fail('$path.tokens', 'must not be empty');
      }
      themes.add(
        ThemeDefinition(
          id: reader.string(map['id'], '$path.id'),
          name: reader.string(map['name'], '$path.name'),
          tokens: Map.unmodifiable(tokens),
        ),
      );
    }

    return ThemesManifest(version: version, themes: List.unmodifiable(themes));
  }

  final int version;
  final List<ThemeDefinition> themes;
}

class ThemeDefinition {
  const ThemeDefinition({
    required this.id,
    required this.name,
    required this.tokens,
  });

  final String id;
  final String name;
  final Map<String, dynamic> tokens;
}
