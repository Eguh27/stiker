import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/data/import/import_queue_store.dart';
import 'package:sticker_studio/features/data/settings/app_settings_dao.dart';
import 'package:sticker_studio/features/queue/data/app_database_provider.dart';
import 'package:sticker_studio/features/queue/data/drift_queue_repository.dart';
import 'package:sticker_studio/features/queue/domain/queue_item.dart';
import 'package:sticker_studio/features/queue/domain/queue_repository.dart';
import 'package:sticker_studio/features/queue/presentation/queue_providers.dart';

import '../../data/support/test_database.dart';

void main() {
  test('Drift nyata: progres + sumber + retry ke DB', () async {
    final AppDatabase database = createTestDatabase();
    addTearDown(database.close);
    final DateTime insertedAt = DateTime.utc(2026, 1, 1);
    final ImportQueueStore store = ImportQueueStore(
      database,
      now: () => insertedAt,
    );
    await store.insertEntry(
      id: 'drift-1',
      localInputPath: '/tmp/IMG_2841.webp',
      sourceType: SourceType.pinterest,
      status: ImportStatus.downloading,
      autoRmbg: true,
      progress: 68,
    );
    await store.insertEntry(
      id: 'drift-2',
      localInputPath: '/tmp/IMG_2838.png',
      sourceType: SourceType.galleryPicker,
      status: ImportStatus.failed,
      autoRmbg: true,
      progress: 36,
      errorMessage: 'rusak',
    );
    final DriftQueueRepository repository = DriftQueueRepository(database);
    final List<QueueItem> items = await repository.fetchQueue();
    expect(items, hasLength(2));
    expect(items.where((QueueItem i) => i.id == 'drift-1').single.progress, 68);
    expect(
      items.where((QueueItem i) => i.id == 'drift-1').single.sourceType.label,
      'Pinterest',
    );
    final ImportQueueEntry? failed = await (database.select(
      database.importQueue,
    )..where((r) => r.id.equals('drift-2'))).getSingleOrNull();
    expect(failed?.errorMessage, 'rusak');

    await repository.retryItem('drift-2');
    final ImportQueueEntry? row = await (database.select(
      database.importQueue,
    )..where((r) => r.id.equals('drift-2'))).getSingleOrNull();
    expect(row?.status, ImportStatus.pending);
    expect(row?.progress, 0);
    expect(row?.errorMessage, isNull);
    expect(row?.updatedAt.isAfter(insertedAt), isTrue);
  });

  test('auto_rmbg tersimpan di app_settings, bukan in-memory', () async {
    final AppDatabase database = createTestDatabase();
    addTearDown(database.close);
    final DriftQueueRepository repository = DriftQueueRepository(database);

    expect(await repository.fetchAutoRmbg(), isTrue);
    await repository.setAutoRmbg(false);

    final AppSetting setting = await database
        .select(database.appSettings)
        .getSingle();
    expect(setting.key, autoRmbgSettingKey);
    expect(setting.value, '0');
    expect(await DriftQueueRepository(database).fetchAutoRmbg(), isFalse);
  });

  test('provider default Drift pakai tabel nyata', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final QueueRepository repository = container.read(queueRepositoryProvider);
    expect(repository, isA<DriftQueueRepository>());
    final AppDatabase database = container.read(appDatabaseProvider);
    expect(database, isA<AppDatabase>());
  });
}
