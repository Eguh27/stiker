const int maxPackTextLength = 28;
const int minPackStickerCount = 3;
const int maxPackStickerCount = 30;

class PackValidationException implements Exception {
  const PackValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

void validatePackText(String label, String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    throw PackValidationException('$label wajib diisi.');
  }
  if (trimmed.length > maxPackTextLength) {
    throw PackValidationException(
      '$label maksimal $maxPackTextLength karakter.',
    );
  }
}

PackValidationException packNotFound(String id) {
  return PackValidationException('Pack $id tidak ditemukan.');
}

void validatePackInput({
  required String name,
  required String author,
  required String trayIconPath,
  required List<String> stickerIds,
}) {
  validatePackText('Nama', name);
  validatePackText('Pembuat', author);
  validatePackTrayIconPath(trayIconPath);
  validatePackStickerIds(stickerIds);
}

void validatePackTrayIconPath(String path) {
  if (path.trim().isEmpty) {
    throw const PackValidationException('Tray icon wajib dipilih.');
  }
}

void validatePackStickerIds(List<String> stickerIds) {
  final int count = stickerIds.length;
  if (count < minPackStickerCount) {
    throw PackValidationException(
      'Pack minimal $minPackStickerCount stiker (saat ini $count).',
    );
  }
  if (count > maxPackStickerCount) {
    throw PackValidationException(
      'Pack maksimal $maxPackStickerCount stiker (saat ini $count).',
    );
  }
  if (stickerIds.toSet().length != count) {
    throw const PackValidationException(
      'Stiker dalam pack tidak boleh duplikat.',
    );
  }
}
