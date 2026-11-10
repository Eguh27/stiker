import 'package:drift/drift.dart';
import 'package:sticker_studio/features/data/app_database.dart';

import 'pack_details.dart';
import 'pack_store.dart';
import 'pack_validation.dart';
import 'pack_version.dart';
import 'sticker_order.dart';

class PackLifecycle {
  PackLifecycle(this._database, this._store, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final PackStore _store;
  final DateTime Function() _now;

  Future<PackDetails> reorderStickers({
    required String packId,
    required List<String> stickerIds,
  }) async {
    validatePackStickerIds(stickerIds);
    return _database.transaction(() async {
      final Pack? existing = await _store.findPack(packId);
      if (existing == null) throw packNotFound(packId);
      final List<String> currentIds = await _store.fetchStickerIds(packId);
      if (!hasSameStickerSet(currentIds, stickerIds)) {
        throw const PackValidationException(
          'Reorder hanya boleh mengubah urutan stiker yang sudah ada.',
        );
      }
      if (hasSameStickerOrder(currentIds, stickerIds)) {
        return PackDetails.fromPack(existing, currentIds);
      }
      await _store.replaceStickers(packId, stickerIds);
      await _store.savePack(
        packId,
        PacksCompanion(
          version: Value(incrementPackVersion(existing.version)),
          updatedAt: Value(_now()),
        ),
      );
      final Pack updated = (await _store.findPack(packId))!;
      return PackDetails.fromPack(updated, stickerIds);
    });
  }

  Future<PackDetails> setSynced(String packId, bool isSynced) {
    return _database.transaction(() async {
      final Pack? existing = await _store.findPack(packId);
      if (existing == null) throw packNotFound(packId);
      final List<String> stickerIds = await _store.fetchStickerIds(packId);
      if (existing.isSynced == isSynced) {
        return PackDetails.fromPack(existing, stickerIds);
      }
      await _store.savePack(
        packId,
        PacksCompanion(
          isSynced: Value(isSynced),
          version: Value(incrementPackVersion(existing.version)),
          updatedAt: Value(_now()),
        ),
      );
      final Pack updated = (await _store.findPack(packId))!;
      return PackDetails.fromPack(updated, stickerIds);
    });
  }

  Future<void> deletePack(String id) {
    return _database.transaction(() async {
      final Pack? existing = await _store.findPack(id);
      if (existing == null) throw packNotFound(id);
      await _store.deletePack(id);
    });
  }
}
