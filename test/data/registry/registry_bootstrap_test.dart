import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/file_system_manager.dart';
import 'package:sticker_studio/features/data/registry/registry_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('sticker_registry_');
  });
  tearDown(() async => root.delete(recursive: true));

  test('menulis manifest ekstraktor bawaan saat belum ada', () async {
    final fileSystemManager = await FileSystemManager.initialize(
      baseDirectory: root,
    );

    final manifest = await RegistryBootstrap.ensureExtractorsManifest(
      fileSystemManager: fileSystemManager,
    );

    expect(await manifest.exists(), isTrue);
    expect(await manifest.readAsString(), contains('pinterest.com'));
    expect(await File('${manifest.path}.part').exists(), isFalse);
  });

  test('tidak menimpa manifest yang sudah diubah pengguna', () async {
    final fileSystemManager = await FileSystemManager.initialize(
      baseDirectory: root,
    );
    final manifest = fileSystemManager.registryFile('extractors_manifest.json');
    await manifest.writeAsString('{"version":1,"extractors":[]}');

    await RegistryBootstrap.ensureExtractorsManifest(
      fileSystemManager: fileSystemManager,
    );

    expect(await manifest.readAsString(), '{"version":1,"extractors":[]}');
  });
}
