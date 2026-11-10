import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/file_system_manager.dart';
import 'package:sticker_studio/features/data/import/url_import_queue_store.dart';
import 'package:sticker_studio/features/data/import/url_import_runner.dart';
import 'package:sticker_studio/features/data/registry/registry_bootstrap.dart';
import 'package:sticker_studio/features/data/registry_engine.dart';
import 'package:sticker_studio/src/rust/frb_generated.dart';

const MethodChannel backgroundImportChannel = MethodChannel(
  'com.example.sticker_studio/background_import',
);

@pragma('vm:entry-point')
Future<void> backgroundImportMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final config = await backgroundImportChannel
        .invokeMapMethod<String, Object?>('getConfig');
    final filesDirectory = config?['filesDir'] as String?;
    final databasePath = config?['databasePath'] as String?;
    if (filesDirectory == null || databasePath == null) {
      throw const FormatException(
        'Konfigurasi impor latar belakang tidak valid',
      );
    }

    final database = AppDatabase(openAppDatabase(File(databasePath)));
    try {
      final fileSystemManager = await FileSystemManager.initialize(
        baseDirectory: Directory(filesDirectory),
      );
      await RegistryBootstrap.ensureExtractorsManifest(
        fileSystemManager: fileSystemManager,
      );
      await RustLib.init();

      final runner = UrlImportRunner(
        store: UrlImportQueueStore(database),
        fileSystemManager: fileSystemManager,
        extractorsManifestPath: fileSystemManager
            .registryFile(RegistryEngine.extractorsManifestFileName)
            .path,
      );
      final processed = await runner.processPending();
      await backgroundImportChannel.invokeMethod<void>('finished', {
        'result': 'success',
        'processed': processed,
      });
    } finally {
      await database.close();
    }
  } catch (error) {
    await backgroundImportChannel.invokeMethod<void>('finished', {
      'result': 'retry',
      'message': error.toString(),
    });
  }
}
