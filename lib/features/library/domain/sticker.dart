/// Model stiker dari `stickers` (db-schema.md). Domain murni, tanpa Flutter.
enum StickerColorKind { lavender, peach, mint, blue, yellow, pink }

enum StickerShape { blob, cloud, flower, burst }

class Sticker {
  const Sticker({
    required this.id,
    required this.label,
    required this.colorKind,
    required this.shape,
    this.sourceLabel = 'Daily',
    this.isNew = false,
    this.filePath,
  });

  final String id;
  final String label;
  final StickerColorKind colorKind;
  final StickerShape shape;
  final String sourceLabel;
  final bool isNew;
  final String? filePath;
}
