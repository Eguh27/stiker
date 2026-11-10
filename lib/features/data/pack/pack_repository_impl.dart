import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/packs/domain/pack_repository.dart';
import 'package:sticker_studio/features/packs/domain/sticker_pack.dart';

import 'pack_details.dart';
import 'pack_editor.dart';
import 'pack_lifecycle.dart';
import 'pack_store.dart';
import 'pack_validation.dart';

/// Pack CRUD Drift + aturan WhatsApp (3..30 stiker, teks <= 28, versi naik).
class PackRepositoryImpl implements PackRepository {
  factory PackRepositoryImpl(
    AppDatabase database, {
    String Function()? createId,
    DateTime Function()? now,
  }) {
    final PackStore store = PackStore(database);
    return PackRepositoryImpl._(
      store,
      PackEditor(database, store, createId: createId, now: now),
      PackLifecycle(database, store, now: now),
    );
  }

  PackRepositoryImpl._(this._store, this._editor, this._lifecycle);

  final PackStore _store;
  final PackEditor _editor;
  final PackLifecycle _lifecycle;

  @override
  Future<List<StickerPack>> fetchPacks() async {
    final List<Pack> packs = await _store.fetchPacks();
    final Map<String, int> counts = await _store.fetchStickerCounts();
    return [
      for (final Pack pack in packs)
        StickerPack(
          id: pack.id,
          name: pack.name,
          stickerCount: counts[pack.id] ?? 0,
          isSynced: pack.isSynced,
        ),
    ];
  }

  Future<PackDetails> fetchPack(String id) async {
    final Pack? pack = await _store.findPack(id);
    if (pack == null) throw packNotFound(id);
    return PackDetails.fromPack(pack, await _store.fetchStickerIds(id));
  }

  Future<PackDetails> createPack({
    required String name,
    required String author,
    required String trayIconPath,
    required List<String> stickerIds,
    List<String> emojis = const [],
    bool isSynced = false,
  }) {
    return _editor.createPack(
      name: name,
      author: author,
      trayIconPath: trayIconPath,
      stickerIds: stickerIds,
      emojis: emojis,
      isSynced: isSynced,
    );
  }

  Future<PackDetails> updatePack({
    required String id,
    required String name,
    required String author,
    required String trayIconPath,
    required List<String> stickerIds,
    List<String>? emojis,
    bool? isSynced,
  }) {
    return _editor.updatePack(
      id: id,
      name: name,
      author: author,
      trayIconPath: trayIconPath,
      stickerIds: stickerIds,
      emojis: emojis,
      isSynced: isSynced,
    );
  }

  Future<PackDetails> reorderStickers({
    required String packId,
    required List<String> stickerIds,
  }) {
    return _lifecycle.reorderStickers(packId: packId, stickerIds: stickerIds);
  }

  Future<PackDetails> setSynced(String packId, bool isSynced) {
    return _lifecycle.setSynced(packId, isSynced);
  }

  Future<void> deletePack(String id) => _lifecycle.deletePack(id);
}
