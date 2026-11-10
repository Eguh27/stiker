import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/data/import/import_exception.dart';
import 'package:sticker_studio/features/data/import/import_queue_watcher.dart';

import 'support/import_test_doubles.dart';
import 'support/import_workspace.dart';

void main() {
  late ImportWorkspace workspace;
  late RecordingImportQueueStore store;

  setUp(() async {
    workspace = await ImportWorkspace.create(
      createQueueStore: RecordingImportQueueStore.new,
    );
    store = workspace.queueStore as RecordingImportQueueStore;
  });
  tearDown(() async => workspace.dispose());

  test(
    'status bergerak PENDING -> DOWNLOADING -> PROCESSING -> DONE',
    () async {
      final source = await workspace.createInput('sticker.png');
      final ids = await workspace.repository.enqueueFiles(
        inputPaths: [source.path],
        sourceType: SourceType.galleryPicker,
      );
      final processor = FakeImportProcessor();
      final watcher = ImportQueueWatcher(store: store, processor: processor);

      expect(
        (await workspace.fetchQueueRows()).single.status,
        ImportStatus.pending,
      );
      await watcher.processPending();

      final row = (await workspace.fetchQueueRows()).single;
      expect(store.transitions, [
        ImportStatus.downloading,
        ImportStatus.processing,
        ImportStatus.done,
      ]);
      expect(processor.processedIds, ids);
      expect(row.status, ImportStatus.done);
      expect(row.progress, 100);
      expect(row.errorMessage, isNull);
    },
  );

  test('satu file gagal tetap FAILED dan antrean lanjut', () async {
    final inputs = await Future.wait([
      workspace.createInput('satu.png'),
      workspace.createInput('dua.png'),
      workspace.createInput('tiga.png'),
    ]);
    final ids = await workspace.repository.enqueueFiles(
      inputPaths: inputs.map((file) => file.path),
      sourceType: SourceType.manualFile,
    );
    final failingId = ids[1];
    final processor = FakeImportProcessor(
      onProcess: (entry) async {
        if (entry.id == failingId) {
          throw const ImportException('Gambar rusak');
        }
      },
    );
    final watcher = ImportQueueWatcher(store: store, processor: processor);

    await watcher.processPending();

    final rows = await workspace.fetchQueueRows();
    final byId = {for (final row in rows) row.id: row};
    expect(byId[ids[0]]!.status, ImportStatus.done);
    expect(byId[failingId]!.status, ImportStatus.failed);
    expect(byId[failingId]!.errorMessage, 'Gambar rusak');
    expect(byId[ids[2]]!.status, ImportStatus.done);
    expect(processor.processedIds, unorderedEquals(ids));
  });
}
