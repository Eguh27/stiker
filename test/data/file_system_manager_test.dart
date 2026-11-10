import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sticker_studio/features/data/file_system_manager.dart';

void main() {
  late Directory baseDirectory;

  setUp(() async {
    baseDirectory = await Directory.systemTemp.createTemp(
      'sticker_studio_files_',
    );
  });

  tearDown(() async {
    if (await baseDirectory.exists()) {
      await baseDirectory.delete(recursive: true);
    }
  });

  Future<FileSystemManager> initializeManager() {
    return FileSystemManager.initialize(baseDirectory: baseDirectory);
  }

  test('initialize membuat app_data dan tiga subfolder', () async {
    final manager = await initializeManager();

    final appDataDirectory = Directory(p.join(baseDirectory.path, 'app_data'));
    expect(manager.appDataDirectory.path, appDataDirectory.path);

    for (final directory in [
      manager.appDataDirectory,
      manager.originalsDirectory,
      manager.stickersDirectory,
      manager.registryDirectory,
    ]) {
      expect(await directory.exists(), isTrue, reason: directory.path);
    }
  });

  test('initialize idempoten dan tidak menghapus file yang ada', () async {
    final manager = await initializeManager();
    final existing = manager.originalFile('existing.jpg');
    await existing.writeAsBytes([1, 2, 3]);

    final initializedAgain = await initializeManager();

    expect(await existing.exists(), isTrue);
    expect(initializedAgain.originalFile('existing.jpg').path, existing.path);
  });

  test('helper path mengarah ke folder yang benar', () async {
    final manager = await initializeManager();
    final appDataPath = p.join(baseDirectory.path, 'app_data');

    expect(
      manager.originalFile('photo.jpg').path,
      p.join(appDataPath, 'originals', 'photo.jpg'),
    );
    expect(
      manager.stickerFile('sticker.webp').path,
      p.join(appDataPath, 'stickers', 'sticker.webp'),
    );
    expect(
      manager.registryFile('extractors_manifest.json').path,
      p.join(appDataPath, 'registry', 'extractors_manifest.json'),
    );
  });

  test('helper path menolak nama file yang keluar folder', () async {
    final manager = await initializeManager();

    for (final fileName in [
      '',
      '.',
      '..',
      '../outside.webp',
      'nested/file.webp',
      p.join(baseDirectory.path, 'absolute.webp'),
    ]) {
      expect(
        () => manager.originalFile(fileName),
        throwsArgumentError,
        reason: fileName,
      );
    }
  });

  test('initialize gagal jika app_data sudah berupa file', () async {
    await File(p.join(baseDirectory.path, 'app_data')).writeAsString('file');

    await expectLater(initializeManager(), throwsA(isA<FileSystemException>()));
  });

  test('initialize gagal jika subfolder sudah berupa file', () async {
    final appDataDirectory = Directory(p.join(baseDirectory.path, 'app_data'));
    await appDataDirectory.create();
    await File(p.join(appDataDirectory.path, 'stickers')).writeAsString('file');

    await expectLater(initializeManager(), throwsA(isA<FileSystemException>()));
  });
}
