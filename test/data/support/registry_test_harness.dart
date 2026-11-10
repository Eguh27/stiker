import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/file_system_manager.dart';
import 'package:sticker_studio/features/data/registry/manifest_exception.dart';
import 'package:sticker_studio/features/data/registry_engine.dart';

class RegistryTestHarness {
  late Directory _baseDirectory;
  late FileSystemManager _fileSystemManager;
  late RegistryEngine engine;

  Future<void> setUp() async {
    _baseDirectory = await Directory.systemTemp.createTemp(
      'sticker_studio_registry_',
    );
    _fileSystemManager = await FileSystemManager.initialize(
      baseDirectory: _baseDirectory,
    );
    engine = RegistryEngine(_fileSystemManager);
  }

  Future<void> tearDown() async {
    if (await _baseDirectory.exists()) {
      await _baseDirectory.delete(recursive: true);
    }
  }

  Future<void> writeManifest(String fileName, Object json) {
    return _fileSystemManager
        .registryFile(fileName)
        .writeAsString(jsonEncode(json));
  }

  Future<void> writeRaw(String fileName, String contents) {
    return _fileSystemManager.registryFile(fileName).writeAsString(contents);
  }

  Matcher manifestError({
    required String source,
    required String messageContains,
  }) {
    return isA<ManifestException>()
        .having((error) => error.source, 'source', source)
        .having((error) => error.message, 'message', contains(messageContains));
  }
}
