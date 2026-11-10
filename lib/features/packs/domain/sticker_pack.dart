/// Model `packs` (db-schema.md). Domain murni, tanpa Flutter.
class StickerPack {
  const StickerPack({
    required this.id,
    required this.name,
    required this.stickerCount,
    required this.isSynced,
    this.author = '',
  });

  final String id;
  final String name;
  final String author;
  final int stickerCount;
  final bool isSynced;

  /// Draft editor pack baru: id kosong sampai `Simpan` membuat pack.
  static const StickerPack empty = StickerPack(
    id: '',
    name: '',
    stickerCount: 0,
    isSynced: false,
  );

  StickerPack copyWith({
    String? name,
    String? author,
    int? stickerCount,
    bool? isSynced,
  }) {
    return StickerPack(
      id: id,
      name: name ?? this.name,
      author: author ?? this.author,
      stickerCount: stickerCount ?? this.stickerCount,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
