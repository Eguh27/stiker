import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/data/import/url_import_queue_store.dart';

import 'support/import_workspace.dart';

void main() {
  late ImportWorkspace workspace;
  late UrlImportQueueStore urlStore;

  setUp(() async {
    workspace = await ImportWorkspace.create();
    urlStore = UrlImportQueueStore(workspace.database);
  });
  tearDown(() async => workspace.dispose());

  test('baris URL tidak diambil watcher impor lokal', () async {
    await urlStore.insertEntry(
      id: 'url-1',
      sourceUrl: 'https://example.com/a.jpg',
      sourceType: SourceType.directImageLink,
      autoRmbg: false,
    );

    expect(await workspace.queueStore.fetchNextPending(), isNull);
    expect((await urlStore.fetchNextPending())?.id, 'url-1');
  });

  test('hasil unduhan diserahkan ke watcher impor lokal', () async {
    await urlStore.insertEntry(
      id: 'url-2',
      sourceUrl: 'https://pinterest.com/pin/1',
      sourceType: SourceType.pinterest,
      autoRmbg: true,
    );
    await urlStore.markDownloading('url-2');

    expect(
      (await workspace.fetchQueueRows()).single.status,
      ImportStatus.downloading,
    );
    await urlStore.markDownloaded('url-2', '/app_data/originals/url-2.jpg');

    final local = await workspace.queueStore.fetchNextPending();
    expect(local?.id, 'url-2');
    expect(local?.status, ImportStatus.pending);
    expect(local?.localInputPath, '/app_data/originals/url-2.jpg');
    expect(await urlStore.fetchNextPending(), isNull);
  });

  test('resetInterrupted mengulang unduhan yang terputus', () async {
    await urlStore.insertEntry(
      id: 'url-3',
      sourceUrl: 'https://example.com/a.png',
      sourceType: SourceType.directImageLink,
      autoRmbg: false,
    );
    await urlStore.markDownloading('url-3');

    expect(await urlStore.resetInterrupted(), 1);

    final row = (await workspace.fetchQueueRows()).single;
    expect(row.status, ImportStatus.pending);
    expect(row.progress, 0);
    expect(row.errorMessage, isNull);
  });

  test('markFailed menyimpan pesan untuk Queue Monitor', () async {
    await urlStore.insertEntry(
      id: 'url-4',
      sourceUrl: 'https://pinterest.com/pin/2',
      sourceType: SourceType.pinterest,
      autoRmbg: false,
    );
    await urlStore.markFailed('url-4', 'Butuh login ke situs sumber');

    final row = (await workspace.fetchQueueRows()).single;
    expect(row.status, ImportStatus.failed);
    expect(row.errorMessage, 'Butuh login ke situs sumber');
  });
}
