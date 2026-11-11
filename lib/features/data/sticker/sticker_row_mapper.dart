import '../app_database.dart' as db;
import '../../library/domain/sticker.dart';

/// Hash stabil antar-sesi (String.hashCode tidak dijamin sama) supaya warna
/// dan bentuk placeholder untuk satu stiker selalu konsisten.
int stableHash(String value) {
  var hash = 7;
  for (final unit in value.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash;
}

/// Baris tabel `stickers` -> model domain, termasuk `filePath` agar gambar
/// asli selalu tampil di library, pack, dan picker.
Sticker stickerFromRow(db.Sticker row) {
  final hash = stableHash(row.id);
  return Sticker(
    id: row.id,
    label: row.id.length > 6 ? row.id.substring(0, 6) : row.id,
    colorKind: StickerColorKind.values[hash % StickerColorKind.values.length],
    shape: StickerShape.values[hash % StickerShape.values.length],
    sourceLabel: row.sourceType.databaseValue.split('_').first,
    isNew: DateTime.now().difference(row.createdAt).inHours < 24,
    filePath: row.filePath,
  );
}

/// Placeholder untuk id yang barisnya sudah tidak ada di database.
Sticker missingSticker(String id) {
  final hash = stableHash(id);
  return Sticker(
    id: id,
    label: id.length > 6 ? id.substring(0, 6) : id,
    colorKind: StickerColorKind.values[hash % StickerColorKind.values.length],
    shape: StickerShape.values[hash % StickerShape.values.length],
  );
}
