import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';

import 'support/import_workspace.dart';

void main() {
  late ImportWorkspace workspace;

  setUp(() async => workspace = await ImportWorkspace.create());
  tearDown(() async => workspace.dispose());

  test('resetInterrupted hanya mengulang status in-flight', () async {
    final inputs = await Future.wait([
      for (var index = 0; index < 4; index++)
        workspace.createInput('state_$index.png'),
    ]);
    final ids = await workspace.repository.enqueueFiles(
      inputPaths: inputs.map((file) => file.path),
      sourceType: SourceType.galleryPicker,
    );
    final store = workspace.queueStore;
    await store.updateStatus(ids[0], ImportStatus.downloading, progress: 10);
    await store.updateStatus(ids[1], ImportStatus.processing, progress: 50);
    await store.markFailed(ids[2], 'rusak');
    await store.updateStatus(ids[3], ImportStatus.done, progress: 100);

    final resetCount = await store.resetInterrupted();

    final rows = {
      for (final row in await workspace.fetchQueueRows()) row.id: row,
    };
    expect(resetCount, 2);
    expect(rows[ids[0]]!.status, ImportStatus.pending);
    expect(rows[ids[0]]!.progress, 0);
    expect(rows[ids[0]]!.errorMessage, isNull);
    expect(rows[ids[1]]!.status, ImportStatus.pending);
    expect(rows[ids[2]]!.status, ImportStatus.failed);
    expect(rows[ids[2]]!.errorMessage, 'rusak');
    expect(rows[ids[3]]!.status, ImportStatus.done);
  });

  test('fetchNextPending mengabaikan baris FAILED dan DONE', () async {
    final source = await workspace.createInput('pending.png');
    final ids = await workspace.repository.enqueueFiles(
      inputPaths: [source.path],
      sourceType: SourceType.manualFile,
    );
    final store = workspace.queueStore;
    await store.markFailed(ids.single, 'rusak');

    expect(await store.fetchNextPending(), isNull);
  });
}
