import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/data/import/import_queue_watcher.dart';
import 'package:sticker_studio/features/data/import/sticker_import_processor.dart';
import 'package:sticker_studio/src/rust/api/errors.dart';

import 'support/import_test_doubles.dart';
import 'support/import_workspace.dart';

void main() {
  late ImportWorkspace workspace;

  setUp(() async => workspace = await ImportWorkspace.create());
  tearDown(() async => workspace.dispose());

  test('watcher menandai DONE setelah sticker tersimpan', () async {
    final source = await workspace.createInput('foto.png');
    final ids = await workspace.repository.enqueueFiles(
      inputPaths: [source.path],
      sourceType: SourceType.galleryShare,
    );
    final processor = StickerImportProcessor(
      stickerStore: workspace.stickerStore,
      fileSystemManager: workspace.fileSystemManager,
      encoder: FakeStickerEncoder().call,
    );
    final watcher = ImportQueueWatcher(
      store: workspace.queueStore,
      processor: processor,
    );

    await watcher.processPending();

    expect((await workspace.fetchQueueRows()).single.status, ImportStatus.done);
    expect(await workspace.fetchSticker(ids.single), isNotNull);
  });

  test('error encoder membuat baris FAILED tanpa sticker', () async {
    final source = await workspace.createInput('rusak.jpg');
    await workspace.repository.enqueueFiles(
      inputPaths: [source.path],
      sourceType: SourceType.manualFile,
    );
    final processor = StickerImportProcessor(
      stickerStore: workspace.stickerStore,
      fileSystemManager: workspace.fileSystemManager,
      encoder: FakeStickerEncoder(error: EncodeError.invalidImage).call,
    );
    final watcher = ImportQueueWatcher(
      store: workspace.queueStore,
      processor: processor,
    );

    await watcher.processPending();

    final row = (await workspace.fetchQueueRows()).single;
    expect(row.status, ImportStatus.failed);
    expect(row.errorMessage, 'Gambar tidak didukung');
    expect(await workspace.fetchSticker(row.id), isNull);
  });
}
