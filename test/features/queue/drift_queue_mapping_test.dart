import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/data/import/import_queue_store.dart';
import 'package:sticker_studio/features/queue/data/drift_queue_repository.dart';
import 'package:sticker_studio/features/queue/domain/queue_item.dart';

import '../../data/support/test_database.dart';

typedef _Mapping = ({
  SourceType source,
  ImportStatus status,
  QueueStatus queueStatus,
  QueueSource queueSource,
});

const List<_Mapping> _mappings = [
  (
    source: SourceType.galleryShare,
    status: ImportStatus.pending,
    queueStatus: QueueStatus.pending,
    queueSource: QueueSource.galleryShare,
  ),
  (
    source: SourceType.galleryPicker,
    status: ImportStatus.downloading,
    queueStatus: QueueStatus.downloading,
    queueSource: QueueSource.galleryPicker,
  ),
  (
    source: SourceType.pinterest,
    status: ImportStatus.processing,
    queueStatus: QueueStatus.processing,
    queueSource: QueueSource.pinterest,
  ),
  (
    source: SourceType.genericUrl,
    status: ImportStatus.failed,
    queueStatus: QueueStatus.failed,
    queueSource: QueueSource.genericUrl,
  ),
  (
    source: SourceType.directImageLink,
    status: ImportStatus.done,
    queueStatus: QueueStatus.done,
    queueSource: QueueSource.directImageLink,
  ),
  (
    source: SourceType.manualFile,
    status: ImportStatus.pending,
    queueStatus: QueueStatus.pending,
    queueSource: QueueSource.manualFile,
  ),
];

void main() {
  test('semua source_type dan status dipetakan ke domain', () async {
    final AppDatabase database = createTestDatabase();
    addTearDown(database.close);
    final ImportQueueStore store = ImportQueueStore(database);

    for (final _Mapping mapping in _mappings) {
      await store.insertEntry(
        id: 'row-${mapping.source.databaseValue}-${mapping.status.databaseValue}',
        localInputPath: '/originals/${mapping.source.databaseValue}.png',
        sourceType: mapping.source,
        status: mapping.status,
        autoRmbg: false,
      );
    }

    final List<QueueItem> items = await DriftQueueRepository(database)
        .fetchQueue();
    expect(items, hasLength(_mappings.length));

    for (final QueueItem item in items) {
      final _Mapping mapping = _mappings.singleWhere(
        (_Mapping entry) =>
            item.id ==
            'row-${entry.source.databaseValue}-${entry.status.databaseValue}',
      );
      expect(item.status, mapping.queueStatus);
      expect(item.sourceType, mapping.queueSource);
      expect(item.title, '${mapping.source.databaseValue}.png');
    }
  });

  test('source_url jadi judul saat local_input_path kosong', () async {
    final AppDatabase database = createTestDatabase();
    addTearDown(database.close);
    await database
        .into(database.importQueue)
        .insert(
          ImportQueueCompanion.insert(
            id: 'url-row',
            sourceUrl: const Value('https://example.com/sticker.png'),
            sourceType: SourceType.genericUrl,
            status: ImportStatus.pending,
            progress: 0,
            autoRmbg: false,
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );

    final List<QueueItem> items = await DriftQueueRepository(database)
        .fetchQueue();
    expect(items.single.title, 'sticker.png');
    expect(items.single.sourceUrl, 'https://example.com/sticker.png');
  });
}
