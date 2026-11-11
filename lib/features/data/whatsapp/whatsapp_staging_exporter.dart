import 'dart:convert';
import 'dart:io';

import 'tray_icon_builder.dart';
import 'whatsapp_sticker_validator.dart';

class WhatsAppExportResult {
  const WhatsAppExportResult({
    required this.stagingPath,
    required this.stickerCount,
    required this.identifier,
  });

  final String stagingPath;
  final int stickerCount;
  final String identifier;
}

/// Kesalahan ekspor dengan pesan yang bisa langsung ditampilkan ke pengguna.
class WhatsAppExportException implements Exception {
  const WhatsAppExportException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WhatsAppStagingExporter {
  const WhatsAppStagingExporter({
    this.trayIconBuilder = const TrayIconBuilder(),
  });

  static const String trayFileName = 'tray.png';

  final TrayIconBuilder trayIconBuilder;

  Future<WhatsAppExportResult> exportPack({
    required String stagingBaseDir,
    required String identifier,
    required String name,
    required String author,
    required List<String> stickerPaths,
    List<String> emojis = const [],
    String? trayIconPath,
  }) async {
    if (stickerPaths.length < 3 || stickerPaths.length > 30) {
      throw ArgumentError('Stiker harus berjumlah 3 sampai 30 untuk WhatsApp');
    }
    _validateStickers(stickerPaths);

    final packDir = Directory('$stagingBaseDir/$identifier');
    if (packDir.existsSync()) packDir.deleteSync(recursive: true);
    packDir.createSync(recursive: true);

    await trayIconBuilder.build(
      sourcePath: trayIconPath ?? stickerPaths.first,
      outputPath: '${packDir.path}/$trayFileName',
    );
    final entries = _copyStickers(packDir, stickerPaths, emojis);
    _writeMetadata(packDir, identifier, name, author, entries);

    return WhatsAppExportResult(
      stagingPath: packDir.path,
      stickerCount: stickerPaths.length,
      identifier: identifier,
    );
  }

  void _validateStickers(List<String> paths) {
    for (var i = 0; i < paths.length; i++) {
      final problem = WhatsAppStickerValidator.checkSticker(paths[i]);
      if (problem != null) {
        throw WhatsAppExportException('Stiker ke-${i + 1}: $problem');
      }
    }
  }

  List<Map<String, dynamic>> _copyStickers(
    Directory packDir,
    List<String> paths,
    List<String> emojis,
  ) {
    return [
      for (var i = 0; i < paths.length; i++)
        _copyOne(packDir, paths[i], i, emojis),
    ];
  }

  Map<String, dynamic> _copyOne(
    Directory packDir,
    String source,
    int index,
    List<String> emojis,
  ) {
    final fileName = '${(index + 1).toString().padLeft(2, '0')}.webp';
    File(source).copySync('${packDir.path}/$fileName');
    return {
      'image_file': fileName,
      'emojis': emojis.isNotEmpty ? emojis : ['😀'],
    };
  }

  void _writeMetadata(
    Directory packDir,
    String identifier,
    String name,
    String author,
    List<Map<String, dynamic>> stickers,
  ) {
    final meta = {
      'android_play_store_link': '',
      'ios_app_store_link': '',
      'publisher_email': '',
      'publisher_website': '',
      'privacy_policy_website': '',
      'license_agreement_website': '',
      'sticker_packs': [
        {
          'identifier': identifier,
          'name': name,
          'publisher': author.trim().isEmpty ? 'Sticker Studio' : author,
          'tray_image_file': trayFileName,
          'image_data_version': DateTime.now().millisecondsSinceEpoch.toString(),
          'avoid_cache': false,
          'animated_sticker_pack': false,
          'stickers': stickers,
        },
      ],
    };
    File('${packDir.path}/metadata.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(meta),
    );
  }
}
