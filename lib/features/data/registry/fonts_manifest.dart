import 'manifest_json.dart';

class FontsManifest {
  const FontsManifest({required this.version, required this.fonts});

  factory FontsManifest.fromJson(
    Map<String, dynamic> json, {
    required String source,
  }) {
    final reader = ManifestJson(json, source: source);
    final version = reader.version;
    final entries = reader.list(json['fonts'], 'fonts');
    final fonts = <FontDefinition>[];

    for (final (index, entry) in entries.indexed) {
      final path = 'fonts[$index]';
      final map = reader.object(entry, path);
      fonts.add(
        FontDefinition(
          id: reader.string(map['id'], '$path.id'),
          family: reader.string(map['family'], '$path.family'),
          file: reader.string(map['file'], '$path.file'),
          licenseNote: reader.optionalString(
            map['license_note'],
            '$path.license_note',
          ),
        ),
      );
    }

    return FontsManifest(version: version, fonts: List.unmodifiable(fonts));
  }

  final int version;
  final List<FontDefinition> fonts;
}

class FontDefinition {
  const FontDefinition({
    required this.id,
    required this.family,
    required this.file,
    this.licenseNote,
  });

  final String id;
  final String family;
  final String file;
  final String? licenseNote;
}
