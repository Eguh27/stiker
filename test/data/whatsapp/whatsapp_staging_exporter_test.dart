import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/whatsapp/tray_icon_builder.dart';
import 'package:sticker_studio/features/data/whatsapp/whatsapp_staging_exporter.dart';

class _FakeTrayBuilder extends TrayIconBuilder {
  const _FakeTrayBuilder();

  @override
  Future<void> build({
    required String sourcePath,
    required String outputPath,
  }) async {
    File(outputPath).writeAsBytesSync(const [1, 2, 3]);
  }
}

/// Header RIFF....WEBP minimal: cukup untuk lolos validasi format.
List<int> _webpBytes() => [
  ...'RIFF'.codeUnits,
  0,
  0,
  0,
  0,
  ...'WEBP'.codeUnits,
  0,
  0,
  0,
  0,
];

void main() {
  late Directory tempDir;
  const exporter = WhatsAppStagingExporter(trayIconBuilder: _FakeTrayBuilder());

  List<String> makeStickers(int count) => [
    for (var i = 0; i < count; i++)
      (File('${tempDir.path}/src$i.webp')..writeAsBytesSync(_webpBytes())).path,
  ];

  setUp(() => tempDir = Directory.systemTemp.createTempSync('wa_staging_'));
  tearDown(() => tempDir.deleteSync(recursive: true));

  test('menolak kurang dari 3 stiker', () {
    expect(
      () => exporter.exportPack(
        stagingBaseDir: tempDir.path,
        identifier: 'pack-1',
        name: 'Pack Test',
        author: 'Author',
        stickerPaths: makeStickers(2),
      ),
      throwsArgumentError,
    );
  });

  test('menolak stiker yang filenya tidak ada, bukan membuat file palsu', () {
    expect(
      () => exporter.exportPack(
        stagingBaseDir: tempDir.path,
        identifier: 'pack-1',
        name: 'Pack Test',
        author: 'Author',
        stickerPaths: ['/tidak/ada/1.webp', ...makeStickers(2)],
      ),
      throwsA(isA<WhatsAppExportException>()),
    );
  });

  test('menolak file yang bukan WebP', () {
    final fake = File('${tempDir.path}/fake.webp')
      ..writeAsStringSync('bukan webp');
    expect(
      () => exporter.exportPack(
        stagingBaseDir: tempDir.path,
        identifier: 'pack-1',
        name: 'Pack Test',
        author: 'Author',
        stickerPaths: [fake.path, ...makeStickers(2)],
      ),
      throwsA(isA<WhatsAppExportException>()),
    );
  });

  test('menolak identifier tidak aman tanpa menghapus staging', () async {
    final keepDir = Directory('${tempDir.path}/pack-1')..createSync();
    final sentinel = File('${keepDir.path}/keep.txt')
      ..writeAsStringSync('aman');
    final stickers = makeStickers(3);

    for (final String identifier in [
      '',
      '..',
      '../keluar',
      'pack/sub',
      'pack name',
      'a' * 65,
    ]) {
      await expectLater(
        exporter.exportPack(
          stagingBaseDir: tempDir.path,
          identifier: identifier,
          name: 'Pack Test',
          author: 'Author',
          stickerPaths: stickers,
        ),
        throwsA(isA<WhatsAppExportException>()),
        reason: 'identifier "$identifier" harus ditolak',
      );
    }

    expect(sentinel.existsSync(), isTrue);
    expect(File('${keepDir.path}/keep.txt').readAsStringSync(), 'aman');
  });

  test('mengekspor 3 stiker, tray.png, dan metadata.json', () async {
    final res = await exporter.exportPack(
      stagingBaseDir: tempDir.path,
      identifier: 'pack-1',
      name: 'Pack Test',
      author: 'Author Test',
      stickerPaths: makeStickers(3),
      emojis: ['🔥', '👍'],
    );

    expect(res.stickerCount, 3);
    final dir = Directory(res.stagingPath);
    final meta = jsonDecode(
      File('${dir.path}/metadata.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final pack = (meta['sticker_packs'] as List).first as Map<String, dynamic>;
    expect(pack['identifier'], 'pack-1');
    expect(pack['publisher'], 'Author Test');
    expect(pack['tray_image_file'], 'tray.png');
    expect((pack['stickers'] as List).first['image_file'], '01.webp');
    expect(File('${dir.path}/tray.png').existsSync(), isTrue);
    for (final name in ['01', '02', '03']) {
      expect(File('${dir.path}/$name.webp').existsSync(), isTrue);
    }
  });
}
