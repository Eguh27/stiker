import 'package:drift/drift.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/import/import_id.dart';

import 'pack_details.dart';
import 'pack_emojis.dart';
import 'pack_store.dart';
import 'pack_validation.dart';
import 'pack_version.dart';
import 'sticker_order.dart';

class PackEditor {
  PackEditor(
    this._database,
    this._store, {
    String Function()? createId,
    DateTime Function()? now,
  }) : _createId = createId ?? createImportId,
       _now = now ?? DateTime.now;

  final AppDatabase _database;
  final PackStore _store;
  final String Function() _createId;
  final DateTime Function() _now;

  Future<PackDetails> createPack({
    required String name,
    required String author,
    required String trayIconPath,
    required List<String> stickerIds,
    List<String> emojis = const [],
    bool isSynced = false,
  }) async {
    final String trimmedName = name.trim();
    final String trimmedAuthor = author.trim();
    final String trimmedTray = trayIconPath.trim();
    validatePackInput(
      name: trimmedName,
      author: trimmedAuthor,
      trayIconPath: trimmedTray,
      stickerIds: stickerIds,
    );
    PackEmojis.validate(emojis);

    return _database.transaction(() async {
      await _store.ensureStickersExist(stickerIds);
      final String id = _createId();
      final DateTime now = _now();
      await _store.insertPack(
        PacksCompanion.insert(
          id: id,
          name: trimmedName,
          author: trimmedAuthor,
          trayIconPath: trimmedTray,
          version: '1',
          isSynced: isSynced,
          emojis: Value(PackEmojis.encode(emojis)),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await _store.replaceStickers(id, stickerIds);
      return PackDetails(
        id: id,
        name: trimmedName,
        author: trimmedAuthor,
        trayIconPath: trimmedTray,
        version: '1',
        isSynced: isSynced,
        stickerIds: stickerIds,
        emojis: emojis,
      );
    });
  }

  Future<PackDetails> updatePack({
    required String id,
    required String name,
    required String author,
    required String trayIconPath,
    required List<String> stickerIds,
    List<String>? emojis,
    bool? isSynced,
  }) async {
    final String trimmedName = name.trim();
    final String trimmedAuthor = author.trim();
    final String trimmedTray = trayIconPath.trim();
    validatePackInput(
      name: trimmedName,
      author: trimmedAuthor,
      trayIconPath: trimmedTray,
      stickerIds: stickerIds,
    );
    if (emojis != null) {
      PackEmojis.validate(emojis);
    }

    return _database.transaction(() async {
      final Pack? existing = await _store.findPack(id);
      if (existing == null) throw packNotFound(id);
      final List<String> currentIds = await _store.fetchStickerIds(id);
      final List<String> currentEmojis = PackEmojis.decode(existing.emojis);
      final List<String> nextEmojis = emojis ?? currentEmojis;
      final bool nextSynced = isSynced ?? existing.isSynced;
      final bool isChanged =
          trimmedName != existing.name ||
          trimmedAuthor != existing.author ||
          trimmedTray != existing.trayIconPath ||
          nextSynced != existing.isSynced ||
          !hasSameStickerOrder(currentIds, stickerIds) ||
          !PackEmojis.hasSameEmojis(currentEmojis, nextEmojis);
      final String version = isChanged
          ? incrementPackVersion(existing.version)
          : existing.version;

      await _store.ensureStickersExist(stickerIds);
      await _store.savePack(
        id,
        PacksCompanion(
          name: Value(trimmedName),
          author: Value(trimmedAuthor),
          trayIconPath: Value(trimmedTray),
          version: Value(version),
          isSynced: Value(nextSynced),
          emojis: Value(PackEmojis.encode(nextEmojis)),
          updatedAt: Value(_now()),
        ),
      );
      if (!hasSameStickerOrder(currentIds, stickerIds)) {
        await _store.replaceStickers(id, stickerIds);
      }
      final Pack updated = (await _store.findPack(id))!;
      return PackDetails.fromPack(updated, stickerIds);
    });
  }
}
