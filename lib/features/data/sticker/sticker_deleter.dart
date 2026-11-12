import 'dart:io';

import 'package:drift/drift.dart';

import '../app_database.dart';

/// Menghapus stiker secara bersih: relasi pack & project, riwayat antrean,
/// baris stiker, lalu file di disk. Database dulu (satu transaksi), file
/// belakangan, supaya kegagalan hapus file tidak meninggalkan baris yatim.
class StickerDeleter {
  StickerDeleter(this._database);

  final AppDatabase _database;

  /// Mengembalikan jumlah stiker yang benar-benar terhapus.
  Future<int> delete(Iterable<String> ids) async {
    final Set<String> idSet = ids.toSet();
    if (idSet.isEmpty) return 0;

    final stickers = await (_database.select(
      _database.stickers,
    )..where((t) => t.id.isIn(idSet))).get();
    final queued = await (_database.select(
      _database.importQueue,
    )..where((t) => t.id.isIn(idSet))).get();

    await _database.transaction(() async {
      final Set<String> packIds = await _detachFromPacks(idSet);
      await (_database.delete(
        _database.projects,
      )..where((t) => t.stickerId.isIn(idSet))).go();
      await (_database.delete(
        _database.importQueue,
      )..where((t) => t.id.isIn(idSet))).go();
      await (_database.delete(
        _database.stickers,
      )..where((t) => t.id.isIn(idSet))).go();
      final Set<String> removedPaths = _paths(stickers);
      for (final String packId in packIds) {
        await _refreshPack(packId, removedPaths);
      }
    });

    await _deleteFiles([
      ..._paths(stickers),
      for (final entry in queued) ?entry.localInputPath,
    ]);
    return stickers.length;
  }

  Set<String> _paths(List<Sticker> stickers) => {
    for (final s in stickers) ...[s.filePath, s.thumbPath],
  };

  Future<Set<String>> _detachFromPacks(Set<String> stickerIds) async {
    final rows = await (_database.select(
      _database.packStickers,
    )..where((t) => t.stickerId.isIn(stickerIds))).get();
    await (_database.delete(
      _database.packStickers,
    )..where((t) => t.stickerId.isIn(stickerIds))).go();
    return {for (final row in rows) row.packId};
  }

  /// Rapatkan urutan stiker, ganti ikon tray bila menunjuk stiker yang dihapus,
  /// dan tandai pack perlu disinkronkan ulang ke WhatsApp.
  Future<void> _refreshPack(String packId, Set<String> removedPaths) async {
    final remaining =
        await (_database.select(_database.packStickers)
              ..where((t) => t.packId.equals(packId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    for (var i = 0; i < remaining.length; i++) {
      await (_database.update(_database.packStickers)..where(
            (t) =>
                t.packId.equals(packId) &
                t.stickerId.equals(remaining[i].stickerId),
          ))
          .write(PackStickersCompanion(position: Value(i)));
    }
    final pack = await (_database.select(
      _database.packs,
    )..where((t) => t.id.equals(packId))).getSingleOrNull();
    if (pack == null) return;
    await (_database.update(
      _database.packs,
    )..where((t) => t.id.equals(packId))).write(
      PacksCompanion(
        trayIconPath: Value(await _trayFor(pack, remaining, removedPaths)),
        isSynced: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<String> _trayFor(
    Pack pack,
    List<PackSticker> remaining,
    Set<String> removedPaths,
  ) async {
    if (!removedPaths.contains(pack.trayIconPath)) return pack.trayIconPath;
    if (remaining.isEmpty) return '';
    final first = await (_database.select(
      _database.stickers,
    )..where((t) => t.id.equals(remaining.first.stickerId))).getSingle();
    return first.thumbPath;
  }

  Future<void> _deleteFiles(Iterable<String> paths) async {
    for (final String path in paths.toSet()) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } on FileSystemException {
        // File sudah hilang/terkunci: baris DB sudah bersih, abaikan.
      }
    }
  }
}
