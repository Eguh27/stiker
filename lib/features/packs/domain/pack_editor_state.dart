import '../../library/domain/sticker.dart';
import 'pack_limits.dart';
import 'sticker_pack.dart';

enum PackEditorStatus { loading, ready, error }

/// State editor pack: draft lokal (nama/pembuat/stiker/tag emoji) disimpan
/// di FE sampai `Simpan` memanggil repository. Tag emoji sengaja client-side
/// karena db-schema belum menyimpannya.
class PackEditorState {
  const PackEditorState._({
    required this.status,
    this.pack,
    this.stickers = const [],
    this.emojiTags = const [],
    this.isSaving = false,
  });

  const PackEditorState.loading() : this._(status: PackEditorStatus.loading);

  const PackEditorState.error() : this._(status: PackEditorStatus.error);

  const PackEditorState.ready({
    required StickerPack pack,
    required List<Sticker> stickers,
    required List<String> emojiTags,
    bool isSaving = false,
  }) : this._(
         status: PackEditorStatus.ready,
         pack: pack,
         stickers: stickers,
         emojiTags: emojiTags,
         isSaving: isSaving,
       );

  final PackEditorStatus status;

  /// Pack yang diedit; hanya diisi saat [status] ready.
  final StickerPack? pack;
  final List<Sticker> stickers;
  final List<String> emojiTags;
  final bool isSaving;

  bool get isReady => status == PackEditorStatus.ready;

  /// Aturan WhatsApp: jumlah stiker dalam batas [min, max].
  bool get isPublishable =>
      stickers.length >= PackLimits.minStickers &&
      stickers.length <= PackLimits.maxStickers;

  bool get canAddSticker => stickers.length < PackLimits.maxStickers;

  bool get canAddEmojiTag => emojiTags.length < PackLimits.maxEmojiTags;

  /// Nama untuk header; kosong memakai placeholder desain 'Tanpa nama'.
  String get displayName {
    final String? name = pack?.name;
    if (name == null || name.isEmpty) return 'Tanpa nama';
    return name;
  }

  PackEditorState copyWith({
    StickerPack? pack,
    List<Sticker>? stickers,
    List<String>? emojiTags,
    bool? isSaving,
  }) {
    return PackEditorState._(
      status: status,
      pack: pack ?? this.pack,
      stickers: stickers ?? this.stickers,
      emojiTags: emojiTags ?? this.emojiTags,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
