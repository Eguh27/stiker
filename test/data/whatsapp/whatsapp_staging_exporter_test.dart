import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/whatsapp/whatsapp_staging_exporter.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('wa_staging_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('WhatsAppStagingExporter menolak kurang dari 3 stiker', () async {
    const exporter = WhatsAppStagingExporter();
    expect(
      () => exporter.exportPack(
        stagingBaseDir: tempDir.path,
        identifier: 'pack-1',
        name: 'Pack Test',
        author: 'Author',
        stickerPaths: ['/tmp/s1.webp', '/tmp/s2.webp'],
      ),
      throwsArgumentError,
    );
  });

  test(
    'WhatsAppStagingExporter berhasil mengekspor pack 3 stiker & metadata.json',
    () async {
      const exporter = WhatsAppStagingExporter();
      final res = await exporter.exportPack(
        stagingBaseDir: tempDir.path,
        identifier: 'pack-1',
        name: 'Pack Test',
        author: 'Author Test',
        stickerPaths: ['/tmp/s1.webp', '/tmp/s2.webp', '/tmp/s3.webp'],
        emojis: ['🔥', '👍'],
      );

      expect(res.stickerCount, 3);
      expect(res.identifier, 'pack-1');

      final dir = Directory(res.stagingPath);
      expect(dir.existsSync(), isTrue);

      final metaFile = File('${dir.path}/metadata.json');
      expect(metaFile.existsSync(), isTrue);

      final meta =
          jsonDecode(metaFile.readAsStringSync()) as Map<String, dynamic>;
      final packs = meta['sticker_packs'] as List<dynamic>;
      expect(packs.length, 1);
      expect(packs.first['identifier'], 'pack-1');
      expect(packs.first['name'], 'Pack Test');
      expect(packs.first['publisher'], 'Author Test');

      final stickers = packs.first['stickers'] as List<dynamic>;
      expect(stickers.length, 3);
      expect(stickers.first['image_file'], '01.webp');

      expect(File('${dir.path}/tray.webp').existsSync(), isTrue);
      expect(File('${dir.path}/01.webp').existsSync(), isTrue);
      expect(File('${dir.path}/02.webp').existsSync(), isTrue);
      expect(File('${dir.path}/03.webp').existsSync(), isTrue);
    },
  );
}
