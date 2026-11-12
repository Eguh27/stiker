import '../../library/domain/sticker.dart';
import 'sticker_pack.dart';

/// Interface list pack. Signature tetap milik `packs_page` (F4 awal);
/// operasi editor ada di [PackEditorRepository].
abstract class PackRepository {
  Future<List<StickerPack>> fetchPacks();
}

/// Isi satu pack untuk editor: metadata + stiker terurut sesuai
/// `pack_stickers.position` (db-schema.md) + emojiTags (v0.3.0).
class PackDetail {
  const PackDetail({
    required this.pack,
    required this.stickers,
    this.emojiTags = const [],
  });

  final StickerPack pack;
  final List<Sticker> stickers;
  final List<String> emojiTags;
}

/// Kontrak editor pack (F4-FE): create/update/reorder. FE memakai
/// `FakePackRepository`; BE mengintegrasikan lewat `PackRepositoryImpl`
/// yang sudah memakai operasi yang sama.
abstract class PackEditorRepository implements PackRepository {
  /// Detail pack + urutan stiker sesuai `pack_stickers.position`.
  Future<PackDetail> fetchPackDetail(String packId);

  /// Buat pack baru; stickers adalah draft stiker yang sudah disusun.
  Future<PackDetail> createPack({
    required String name,
    required String author,
    List<Sticker> stickers = const [],
    List<String> emojiTags = const [],
  });

  /// Simpan metadata pack (nama/pembuat/emoji) dan stiker.
  Future<void> updatePack({
    required String packId,
    required String name,
    required String author,
    List<Sticker>? stickers,
    List<String>? emojiTags,
  });

  /// Simpan urutan stiker; id harus milik pack yang ada.
  Future<void> reorderStickers({
    required String packId,
    required List<String> stickerIds,
  });

  /// Hapus pack beserta seluruh baris `pack_stickers`. Stiker library tetap.
  Future<void> deletePack(String packId);
}
