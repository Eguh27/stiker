import 'dart:convert';
import 'dart:io';

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

class WhatsAppStagingExporter {
  const WhatsAppStagingExporter();

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

    final packDir = Directory('$stagingBaseDir/$identifier');
    if (!packDir.existsSync()) {
      packDir.createSync(recursive: true);
    }

    // Write tray icon
    final trayFile = File('${packDir.path}/tray.webp');
    if (trayIconPath != null && File(trayIconPath).existsSync()) {
      File(trayIconPath).copySync(trayFile.path);
    } else {
      trayFile.writeAsBytesSync(const [
        82,
        73,
        70,
        70,
        0,
        0,
        0,
        0,
        87,
        69,
        66,
        80,
      ]);
    }

    // Write stickers
    final stickerEntries = <Map<String, dynamic>>[];
    for (var i = 0; i < stickerPaths.length; i++) {
      final fileName = '${(i + 1).toString().padLeft(2, '0')}.webp';
      final destFile = File('${packDir.path}/$fileName');
      final srcFile = File(stickerPaths[i]);
      if (srcFile.existsSync()) {
        srcFile.copySync(destFile.path);
      } else {
        destFile.writeAsBytesSync(const [
          82,
          73,
          70,
          70,
          0,
          0,
          0,
          0,
          87,
          69,
          66,
          80,
        ]);
      }
      stickerEntries.add({
        'image_file': fileName,
        'emojis': emojis.isNotEmpty ? emojis : ['😀'],
      });
    }

    // Write metadata.json
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
          'publisher': author,
          'tray_image_file': 'tray.webp',
          'image_data_version': '1',
          'avoid_cache': false,
          'animated_sticker_pack': false,
          'stickers': stickerEntries,
        },
      ],
    };

    final metaFile = File('${packDir.path}/metadata.json');
    metaFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(meta),
    );

    return WhatsAppExportResult(
      stagingPath: packDir.path,
      stickerCount: stickerPaths.length,
      identifier: identifier,
    );
  }
}
