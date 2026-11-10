import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/library/domain/sticker.dart' as domain;
import 'package:sticker_studio/features/packs/domain/pack_repository.dart';
import 'package:sticker_studio/features/packs/domain/sticker_pack.dart';

import 'pack_details.dart';
import 'pack_repository_impl.dart';

/// Adapter Drift: menjembatani [PackRepositoryImpl] (data-layer)
/// ke [PackEditorRepository] (domain UI editor).
class DriftPackEditorAdapter implements PackEditorRepository {
  DriftPackEditorAdapter(this._database, [PackRepositoryImpl? repository])
    : _repository = repository ?? PackRepositoryImpl(_database);

  final AppDatabase _database;
  final PackRepositoryImpl _repository;

  @override
  Future<List<StickerPack>> fetchPacks() => _repository.fetchPacks();

  @override
  Future<PackDetail> fetchPackDetail(String packId) async {
    final PackDetails details = await _repository.fetchPack(packId);
    final List<domain.Sticker> stickers = await _fetchDomainStickers(
      details.stickerIds,
    );
    return PackDetail(
      pack: StickerPack(
        id: details.id,
        name: details.name,
        author: details.author,
        stickerCount: details.stickerCount,
        isSynced: details.isSynced,
      ),
      stickers: stickers,
      emojiTags: details.emojis,
    );
  }

  @override
  Future<PackDetail> createPack({
    required String name,
    required String author,
    List<domain.Sticker> stickers = const [],
    List<String> emojiTags = const [],
  }) async {
    final List<String> stickerIds = [for (final s in stickers) s.id];
    await _ensureStickersExist(stickerIds);
    final String trayPath = await _resolveTray(stickerIds);

    final PackDetails details = await _repository.createPack(
      name: name,
      author: author,
      trayIconPath: trayPath,
      stickerIds: stickerIds,
      emojis: emojiTags,
    );

    return PackDetail(
      pack: StickerPack(
        id: details.id,
        name: details.name,
        author: details.author,
        stickerCount: details.stickerCount,
        isSynced: details.isSynced,
      ),
      stickers: stickers,
      emojiTags: details.emojis,
    );
  }

  @override
  Future<void> updatePack({
    required String packId,
    required String name,
    required String author,
    List<domain.Sticker>? stickers,
    List<String>? emojiTags,
  }) async {
    final PackDetails existing = await _repository.fetchPack(packId);
    final List<String> stickerIds = stickers != null
        ? [for (final s in stickers) s.id]
        : existing.stickerIds;
    await _ensureStickersExist(stickerIds);
    final String trayPath = await _resolveTray(stickerIds);
    await _repository.updatePack(
      id: packId,
      name: name,
      author: author.trim().isEmpty ? 'Sticker Studio' : author,
      trayIconPath: trayPath,
      stickerIds: stickerIds,
      emojis: emojiTags,
      isSynced: existing.isSynced,
    );
  }

  @override
  Future<void> reorderStickers({
    required String packId,
    required List<String> stickerIds,
  }) {
    return _repository.reorderStickers(packId: packId, stickerIds: stickerIds);
  }

  Future<List<domain.Sticker>> _fetchDomainStickers(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await (_database.select(
      _database.stickers,
    )..where((t) => t.id.isIn(ids))).get();
    final Map<String, Sticker> map = {for (final row in rows) row.id: row};
    const colors = domain.StickerColorKind.values;
    const shapes = domain.StickerShape.values;
    return [
      for (int i = 0; i < ids.length; i++)
        domain.Sticker(
          id: ids[i],
          label: 'Stiker ${i + 1}',
          colorKind: colors[i % colors.length],
          shape: shapes[i % shapes.length],
          sourceLabel: map[ids[i]]?.sourceType.name ?? 'Daily',
        ),
    ];
  }

  Future<void> _ensureStickersExist(List<String> ids) async {
    if (ids.isEmpty) return;
    final Set<String> found =
        (await (_database.selectOnly(_database.stickers)
                  ..addColumns([_database.stickers.id])
                  ..where(_database.stickers.id.isIn(ids)))
                .get())
            .map((r) => r.read(_database.stickers.id)!)
            .toSet();
    final List<String> missing = [
      for (final id in ids)
        if (!found.contains(id)) id,
    ];
    if (missing.isEmpty) return;
    final DateTime now = DateTime.now();
    await _database.batch((batch) {
      batch.insertAll(_database.stickers, [
        for (final id in missing)
          StickersCompanion.insert(
            id: id,
            filePath: '/app_data/stickers/$id.webp',
            thumbPath: '/app_data/stickers/$id.webp',
            width: 512,
            height: 512,
            sizeKb: 50,
            sha256: id,
            sourceType: SourceType.manualFile,
            createdAt: now,
          ),
      ]);
    });
  }

  Future<String> _resolveTray(List<String> ids) async {
    if (ids.isEmpty) return '/app_data/tray/default.webp';
    final row = await (_database.select(
      _database.stickers,
    )..where((t) => t.id.equals(ids.first))).getSingleOrNull();
    return row?.thumbPath ??
        row?.filePath ??
        '/app_data/tray/${ids.first}.webp';
  }
}
