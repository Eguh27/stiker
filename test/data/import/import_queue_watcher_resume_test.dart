import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
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

  test('watcher baru melanjutkan baris DOWNLOADING/PROCESSING', () async {
    final inputs = await Future.wait([
      workspace.createInput('interrupted_1.png'),
      workspace.createInput('interrupted_2.png'),
    ]);
    final ids = await workspace.repository.enqueueFiles(
      inputPaths: inputs.map((file) => file.path),
      sourceType: SourceType.galleryPicker,
    );
    await store.updateStatus(ids[0], ImportStatus.downloading, progress: 10);
    await store.updateStatus(ids[1], ImportStatus.processing, progress: 50);

    final processor = FakeImportProcessor();
    final restartedWatcher = ImportQueueWatcher(
      store: store,
      processor: processor,
    );
    store.transitions.clear();
    await restartedWatcher.processPending();

    final rows = await workspace.fetchQueueRows();
    expect(store.resetCount, 1);
    expect(rows.every((row) => row.status == ImportStatus.done), isTrue);
    expect(processor.processedIds, unorderedEquals(ids));
    expect(store.transitions, [
      ImportStatus.downloading,
      ImportStatus.processing,
      ImportStatus.done,
      ImportStatus.downloading,
      ImportStatus.processing,
      ImportStatus.done,
    ]);
  });

  test('bulk 30 file diproses berurutan tanpa memblokir event loop', () async {
    final inputs = await Future.wait([
      for (var index = 0; index < 30; index++)
        workspace.createInput('drain_$index.png'),
    ]);
    await workspace.repository.enqueueFiles(
      inputPaths: inputs.map((file) => file.path),
      sourceType: SourceType.galleryPicker,
    );
    final watcher = ImportQueueWatcher(
      store: store,
      processor: FakeImportProcessor(),
    );
    var timerFired = false;

    final processing = watcher.processPending();
    Timer.run(() => timerFired = true);
    await processing;

    final rows = await workspace.fetchQueueRows();
    expect(timerFired, isTrue);
    expect(rows, hasLength(30));
    expect(rows.every((row) => row.status == ImportStatus.done), isTrue);
  });

  test('processPending kedua memakai proses yang sedang berjalan', () async {
    final source = await workspace.createInput('single.png');
    await workspace.repository.enqueueFiles(
      inputPaths: [source.path],
      sourceType: SourceType.galleryPicker,
    );
    final watcher = ImportQueueWatcher(
      store: store,
      processor: FakeImportProcessor(),
    );

    final first = watcher.processPending();
    final second = watcher.processPending();

    expect(identical(first, second), isTrue);
    await first;
  });
}
