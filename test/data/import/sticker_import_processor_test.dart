import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/data/import/import_exception.dart';
import 'package:sticker_studio/features/data/import/sticker_import_processor.dart';

import '../support/test_database.dart';
import 'support/import_test_doubles.dart';
import 'support/import_workspace.dart';

void main() {
  late ImportWorkspace workspace;

  setUp(() async => workspace = await ImportWorkspace.create());
  tearDown(() async => workspace.dispose());

  test('encode lalu simpan metadata dan baris stickers', () async {
    final source = await workspace.createInput('foto.jpg');
    final ids = await workspace.repository.enqueueFiles(
      inputPaths: [source.path],
      sourceType: SourceType.galleryPicker,
    );
    final entry = (await workspace.fetchQueueRows()).single;
    final payload = List<int>.generate(2048, (index) => index % 256);
    final encoder = FakeStickerEncoder(payload: payload);
    final processor = StickerImportProcessor(
      stickerStore: workspace.stickerStore,
      fileSystemManager: workspace.fileSystemManager,
      now: () => testTimestamp,
      encoder: encoder.call,
    );

    await processor.process(entry);

    final sticker = await workspace.fetchSticker(ids.single);
    expect(sticker, isNotNull);
    expect(
      sticker!.filePath,
      workspace.fileSystemManager.stickerFile('${ids.single}.webp').path,
    );
    expect(sticker.thumbPath, sticker.filePath);
    expect(sticker.width, 512);
    expect(sticker.height, 512);
    expect(sticker.sizeKb, 2);
    expect(sticker.sha256, sha256.convert(payload).toString());
    expect(sticker.sourceType, SourceType.galleryPicker);
    expect(sticker.createdAt.isAtSameMomentAs(testTimestamp), isTrue);
    expect(encoder.inputPath, entry.localInputPath);
    expect(encoder.targetSizeKb, 100);
  });

  test('input tanpa localInputPath ditolak', () async {
    final processor = StickerImportProcessor(
      stickerStore: workspace.stickerStore,
      fileSystemManager: workspace.fileSystemManager,
    );
    final entry = ImportQueueEntry(
      id: 'tanpa-path',
      sourceType: SourceType.manualFile,
      status: ImportStatus.pending,
      progress: 0,
      autoRmbg: false,
      createdAt: testTimestamp,
      updatedAt: testTimestamp,
    );

    await expectLater(
      processor.process(entry),
      throwsA(isA<ImportException>()),
    );
  });
}
