import 'dart:io';

import 'package:flutter/services.dart';

import '../file_system_manager.dart';
import '../registry_engine.dart';

class RegistryBootstrap {
  RegistryBootstrap._();

  static const String defaultExtractorsAsset =
      'assets/registry/extractors_manifest.json';

  static Future<File> ensureExtractorsManifest({
    required FileSystemManager fileSystemManager,
    AssetBundle? bundle,
  }) async {
    final manifest = fileSystemManager.registryFile(
      RegistryEngine.extractorsManifestFileName,
    );
    if (await manifest.exists()) {
      return manifest;
    }

    final contents = await (bundle ?? rootBundle).loadString(
      defaultExtractorsAsset,
    );
    final part = File('${manifest.path}.part');
    try {
      await part.writeAsString(contents, flush: true);
      await part.rename(manifest.path);
    } finally {
      if (await part.exists()) {
        await part.delete();
      }
    }
    return manifest;
  }
}
