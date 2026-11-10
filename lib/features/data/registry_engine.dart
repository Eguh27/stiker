import 'dart:convert';
import 'dart:io';

import 'file_system_manager.dart';
import 'registry/extractors_manifest.dart';
import 'registry/fonts_manifest.dart';
import 'registry/manifest_exception.dart';
import 'registry/presets_manifest.dart';
import 'registry/themes_manifest.dart';

class RegistryEngine {
  RegistryEngine(this._fileSystemManager);

  static const String extractorsManifestFileName = 'extractors_manifest.json';
  static const String presetsManifestFileName = 'presets_manifest.json';
  static const String fontsManifestFileName = 'fonts_manifest.json';
  static const String themesManifestFileName = 'themes_manifest.json';

  final FileSystemManager _fileSystemManager;

  Future<ExtractorsManifest> loadExtractorsManifest() =>
      _load(extractorsManifestFileName, ExtractorsManifest.fromJson);

  Future<PresetsManifest> loadPresetsManifest() =>
      _load(presetsManifestFileName, PresetsManifest.fromJson);

  Future<FontsManifest> loadFontsManifest() =>
      _load(fontsManifestFileName, FontsManifest.fromJson);

  Future<ThemesManifest> loadThemesManifest() =>
      _load(themesManifestFileName, ThemesManifest.fromJson);

  Future<T> _load<T>(
    String fileName,
    T Function(Map<String, dynamic> json, {required String source}) parse,
  ) async {
    final file = _fileSystemManager.registryFile(fileName);
    if (!await file.exists()) {
      throw ManifestException(
        source: fileName,
        message: 'file not found at ${file.path}',
      );
    }

    final String contents;
    try {
      contents = await file.readAsString();
    } on FileSystemException catch (error) {
      throw ManifestException(
        source: fileName,
        message: 'cannot read file: ${error.message}',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(contents);
    } on FormatException catch (error) {
      throw ManifestException(
        source: fileName,
        message: 'invalid JSON: ${error.message}',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw ManifestException(
        source: fileName,
        message: 'root must be a JSON object',
      );
    }

    return parse(decoded, source: fileName);
  }
}
