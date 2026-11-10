import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/data/file_system_manager.dart';
import 'package:sticker_studio/features/data/import/url_import_queue_store.dart';
import 'package:sticker_studio/features/data/import/url_import_runner.dart';
import 'package:sticker_studio/features/data/registry_engine.dart';
import 'package:sticker_studio/src/rust/api/encode.dart';

/// Runner di foreground untuk memproses antrean URL dan gambar secara langsung.
class ForegroundImportRunner {
  ForegroundImportRunner(this._database);

  final AppDatabase _database;
  bool _isProcessing = false;

  Future<void> processAllPending({VoidCallback? onStickerAdded}) async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      final fs = await FileSystemManager.initialize();
      final manifest = fs.registryFile(
        RegistryEngine.extractorsManifestFileName,
      );

      // 1. Download URL pending
      final urlRunner = UrlImportRunner(
        store: UrlImportQueueStore(_database),
        fileSystemManager: fs,
        extractorsManifestPath: manifest.path,
      );
      await urlRunner.processPending();

      // 2. Proses semua item yang sudah memiliki localInputPath tapi belum DONE
      final readyItems =
          await (_database.select(_database.importQueue)..where(
                (t) =>
                    t.localInputPath.isNotNull() &
                    t.status.equalsValue(ImportStatus.pending),
              ))
              .get();

      final appDir = await getApplicationDocumentsDirectory();
      final stickersDir = Directory('${appDir.path}/stickers');
      if (!stickersDir.existsSync()) stickersDir.createSync(recursive: true);

      for (final item in readyItems) {
        final localPath = item.localInputPath;
        if (localPath == null || !File(localPath).existsSync()) continue;

        final outWebp = '${stickersDir.path}/${item.id}.webp';
        try {
          await encodeWhatsappWebp(
            inputPath: localPath,
            outputPath: outWebp,
            targetSizeKb: 100,
          );
        } catch (_) {
          await File(localPath).copy(outWebp);
        }

        // Simpan ke tabel stickers
        await _database
            .into(_database.stickers)
            .insertOnConflictUpdate(
              StickersCompanion.insert(
                id: item.id,
                filePath: outWebp,
                thumbPath: outWebp,
                sourceType: item.sourceType,
                sha256: 'sha-${item.id}',
                width: 512,
                height: 512,
                sizeKb: 50,
                createdAt: DateTime.now(),
              ),
            );

        // Tandai item antrean DONE
        await (_database.update(
          _database.importQueue,
        )..where((t) => t.id.equals(item.id))).write(
          const ImportQueueCompanion(
            status: Value(ImportStatus.done),
            progress: Value(100),
          ),
        );

        onStickerAdded?.call();
      }
    } catch (e) {
      debugPrint('ForegroundImportRunner error: $e');
    } finally {
      _isProcessing = false;
    }
  }
}
