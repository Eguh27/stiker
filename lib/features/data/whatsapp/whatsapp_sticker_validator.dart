import 'dart:io';

/// Validasi file stiker sebelum diserahkan ke WhatsApp.
/// WhatsApp menolak seluruh pack bila satu stiker tidak memenuhi syarat.
class WhatsAppStickerValidator {
  const WhatsAppStickerValidator._();

  static const int maxStickerBytes = 100 * 1024;
  static const int maxTrayBytes = 50 * 1024;

  /// Mengembalikan pesan kesalahan, atau `null` bila file valid.
  static String? checkSticker(String path) {
    final file = File(path);
    if (path.isEmpty || !file.existsSync()) {
      return 'File stiker tidak ditemukan';
    }
    if (file.lengthSync() > maxStickerBytes) {
      return 'Stiker melebihi 100 KB';
    }
    return _isWebp(file) ? null : 'Stiker bukan format WebP';
  }

  static bool _isWebp(File file) {
    final raf = file.openSync();
    try {
      final head = raf.readSync(12);
      if (head.length < 12) return false;
      final riff = String.fromCharCodes(head.sublist(0, 4));
      final webp = String.fromCharCodes(head.sublist(8, 12));
      return riff == 'RIFF' && webp == 'WEBP';
    } finally {
      raf.closeSync();
    }
  }
}
