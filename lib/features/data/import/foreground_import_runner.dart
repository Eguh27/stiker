import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/file_system_manager.dart';
import 'package:sticker_studio/features/data/import/import_queue_store.dart';
import 'package:sticker_studio/features/data/import/import_queue_watcher.dart';
import 'package:sticker_studio/features/data/import/imported_sticker_store.dart';
import 'package:sticker_studio/features/data/import/pack_assigning_processor.dart';
import 'package:sticker_studio/features/data/import/source_pack_assigner.dart';
import 'package:sticker_studio/features/data/import/sticker_import_processor.dart';
import 'package:sticker_studio/features/data/import/url_import_queue_store.dart';
import 'package:sticker_studio/features/data/import/url_import_runner.dart';
import 'package:sticker_studio/features/data/registry_engine.dart';
import 'package:sticker_studio/features/queue/data/app_database_provider.dart';

final foregroundImportRunnerProvider = Provider<ForegroundImportRunner>((ref) {
  return ForegroundImportRunner(ref.watch(appDatabaseProvider));
});

/// Menjalankan antrean impor saat app aktif: unduh URL, encode WebP, simpan
/// stiker, lalu masukkan ke pack sumber. Pemicu yang datang saat sedang
/// berjalan (mis. share baru) tidak hilang: putaran diulang sampai tuntas.
class ForegroundImportRunner {
  ForegroundImportRunner(this._database);

  final AppDatabase _database;
  Future<void>? _active;
  bool _rerunRequested = false;

  Future<void> processAllPending({VoidCallback? onStickerAdded}) {
    final active = _active;
    if (active != null) {
      _rerunRequested = true;
      return active;
    }
    final run = _drain(onStickerAdded).whenComplete(() => _active = null);
    _active = run;
    return run;
  }

  Future<void> _drain(VoidCallback? onStickerAdded) async {
    do {
      _rerunRequested = false;
      try {
        await _runOnce(onStickerAdded);
      } catch (error) {
        debugPrint('ForegroundImportRunner error: $error');
      }
    } while (_rerunRequested);
  }

  Future<void> _runOnce(VoidCallback? onStickerAdded) async {
    final fs = await FileSystemManager.initialize();
    await UrlImportRunner(
      store: UrlImportQueueStore(_database),
      fileSystemManager: fs,
      extractorsManifestPath: fs
          .registryFile(RegistryEngine.extractorsManifestFileName)
          .path,
    ).processPending();

    final processor = PackAssigningProcessor(
      inner: StickerImportProcessor(
        stickerStore: ImportedStickerStore(_database),
        fileSystemManager: fs,
      ),
      assigner: SourcePackAssigner(_database),
      fileSystemManager: fs,
      onStickerAdded: onStickerAdded,
    );
    await ImportQueueWatcher(
      store: ImportQueueStore(_database),
      processor: processor,
    ).processPending();
  }
}
