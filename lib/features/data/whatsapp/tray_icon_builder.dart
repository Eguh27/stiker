import 'dart:io';
import 'dart:ui' as ui;

/// Membuat ikon tray 96x96 PNG (syarat WhatsApp) dari salah satu stiker.
class TrayIconBuilder {
  const TrayIconBuilder();

  static const int size = 96;

  Future<void> build({
    required String sourcePath,
    required String outputPath,
  }) async {
    final bytes = await File(sourcePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: size,
      targetHeight: size,
    );
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    frame.image.dispose();
    if (data == null) throw StateError('Gagal membuat ikon tray');
    await File(outputPath).writeAsBytes(data.buffer.asUint8List(), flush: true);
  }
}
