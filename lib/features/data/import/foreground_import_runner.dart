import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/data/file_system_manager.dart';
import 'package:sticker_studio/features/data/import/url_import_queue_store.dart';
import 'package:sticker_studio/features/data/import/url_import_runner.dart';
import 'package:sticker_studio/features/data/registry_engine.dart';
import 'package:sticker_studio/features/queue/data/app_database_provider.dart';
import 'package:sticker_studio/src/rust/api/encode.dart';

final foregroundImportRunnerProvider = Provider<ForegroundImportRunner>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ForegroundImportRunner(db);
});

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

        // Tambahkan otomatis ke pack berdasarkan sumber (e.g. Pinterest)
        await _addToSourcePack(item, outWebp);

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

  Future<void> _addToSourcePack(
    ImportQueueEntry item,
    String stickerPath,
  ) async {
    final packName = _resolvePackName(item);
    final now = DateTime.now();

    var pack = await (_database.select(
      _database.packs,
    )..where((t) => t.name.equals(packName))).getSingleOrNull();

    if (pack == null) {
      final packId =
          'pack-${packName.toLowerCase()}-${now.millisecondsSinceEpoch % 10000}';
      await _database
          .into(_database.packs)
          .insert(
            PacksCompanion.insert(
              id: packId,
              name: packName,
              author: 'Sticker Studio',
              trayIconPath: stickerPath,
              version: '1',
              isSynced: false,
              createdAt: now,
              updatedAt: now,
            ),
          );
      pack = await (_database.select(
        _database.packs,
      )..where((t) => t.id.equals(packId))).getSingle();
    }

    final existingStickers = await (_database.select(
      _database.packStickers,
    )..where((t) => t.packId.equals(pack!.id))).get();

    final alreadyInPack = existingStickers.any((s) => s.stickerId == item.id);
    if (!alreadyInPack) {
      await _database
          .into(_database.packStickers)
          .insertOnConflictUpdate(
            PackStickersCompanion.insert(
              packId: pack.id,
              stickerId: item.id,
              position: existingStickers.length,
            ),
          );
    }
  }

  String _resolvePackName(ImportQueueEntry item) {
    final url = item.sourceUrl?.toLowerCase() ?? '';
    if (url.contains('pinterest') || item.sourceType == SourceType.pinterest) {
      return 'Pinterest';
    }
    if (url.contains('instagram')) {
      return 'Instagram';
    }
    if (url.contains('twitter') || url.contains('x.com')) {
      return 'Twitter';
    }
    if (item.sourceType == SourceType.galleryShare ||
        item.sourceType == SourceType.galleryPicker) {
      return 'Galeri';
    }
    if (url.isNotEmpty) {
      final host = Uri.tryParse(url)?.host;
      if (host != null && host.isNotEmpty) {
        final parts = host.split('.');
        final domainName = parts.length >= 2 ? parts[parts.length - 2] : host;
        return domainName.substring(0, 1).toUpperCase() +
            domainName.substring(1);
      }
    }
    return 'Unduhan';
  }
}
