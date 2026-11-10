import 'package:drift/drift.dart';
import 'package:sticker_studio/features/data/app_database.dart';

import 'pack_validation.dart';

class PackStore {
  PackStore(this._database);

  final AppDatabase _database;

  Future<List<Pack>> fetchPacks() {
    return (_database.select(_database.packs)..orderBy([
          (row) => OrderingTerm.desc(row.updatedAt),
          (row) => OrderingTerm.asc(row.id),
        ]))
        .get();
  }

  Future<Pack?> findPack(String id) {
    return (_database.select(
      _database.packs,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Future<List<String>> fetchStickerIds(String packId) {
    return (_database.select(_database.packStickers)
          ..where((row) => row.packId.equals(packId))
          ..orderBy([(row) => OrderingTerm.asc(row.position)]))
        .map((row) => row.stickerId)
        .get();
  }

  Future<Map<String, int>> fetchStickerCounts() async {
    final count = _database.packStickers.stickerId.count();
    final rows =
        await (_database.selectOnly(_database.packStickers)
              ..addColumns([_database.packStickers.packId, count])
              ..groupBy([_database.packStickers.packId]))
            .get();
    return {
      for (final row in rows)
        row.read(_database.packStickers.packId)!: row.read(count) ?? 0,
    };
  }

  Future<void> ensureStickersExist(Iterable<String> stickerIds) async {
    final Set<String> ids = stickerIds.toSet();
    if (ids.isEmpty) return;
    final rows =
        await (_database.selectOnly(_database.stickers)
              ..addColumns([_database.stickers.id])
              ..where(_database.stickers.id.isIn(ids)))
            .get();
    final Set<String> found = {
      for (final row in rows) row.read(_database.stickers.id)!,
    };
    final Set<String> missing = ids.difference(found);
    if (missing.isNotEmpty) {
      throw PackValidationException(
        'Stiker tidak ditemukan: ${missing.join(', ')}.',
      );
    }
  }

  Future<void> insertPack(PacksCompanion pack) {
    return _database.into(_database.packs).insert(pack);
  }

  Future<void> savePack(String id, PacksCompanion pack) {
    return (_database.update(
      _database.packs,
    )..where((row) => row.id.equals(id))).write(pack);
  }

  Future<void> replaceStickers(String packId, List<String> stickerIds) async {
    await (_database.delete(
      _database.packStickers,
    )..where((row) => row.packId.equals(packId))).go();
    await _database.batch((batch) {
      batch.insertAll(_database.packStickers, [
        for (int index = 0; index < stickerIds.length; index++)
          PackStickersCompanion.insert(
            packId: packId,
            stickerId: stickerIds[index],
            position: index,
          ),
      ]);
    });
  }

  Future<void> deletePack(String id) async {
    await (_database.delete(
      _database.packStickers,
    )..where((row) => row.packId.equals(id))).go();
    await (_database.delete(
      _database.packs,
    )..where((row) => row.id.equals(id))).go();
  }
}
