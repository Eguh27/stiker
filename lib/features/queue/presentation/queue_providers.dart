import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_studio/features/data/import/foreground_import_runner.dart';

import '../data/app_database_provider.dart';
import '../data/drift_queue_repository.dart';
import '../domain/queue_item.dart';
import '../domain/queue_repository.dart';

final queueRepositoryProvider = Provider<QueueRepository>((ref) {
  return DriftQueueRepository(ref.watch(appDatabaseProvider));
});

final foregroundImportRunnerProvider = Provider<ForegroundImportRunner>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ForegroundImportRunner(db);
});

final queueListProvider = FutureProvider<List<QueueItem>>((ref) async {
  final QueueRepository repository = ref.watch(queueRepositoryProvider);
  return repository.fetchQueue();
});

final queueStreamProvider = StreamProvider<List<QueueItem>>((ref) async* {
  final QueueRepository repository = ref.watch(queueRepositoryProvider);
  yield* repository.watchQueue();
});

class AutoRmbgNotifier extends Notifier<bool> {
  @override
  bool build() {
    Future<void>.microtask(() async {
      final QueueRepository repository = ref.read(queueRepositoryProvider);
      state = await repository.fetchAutoRmbg();
    });
    return true;
  }

  Future<void> setEnabled(bool enabled) async {
    final QueueRepository repository = ref.read(queueRepositoryProvider);
    state = enabled;
    await repository.setAutoRmbg(enabled);
  }
}

final autoRmbgProvider = NotifierProvider<AutoRmbgNotifier, bool>(
  AutoRmbgNotifier.new,
);

/// Tab: 0 Dalam proses (pending/downloading/processing/failed),
/// 1 Baru Diimpor (done).
bool isActiveItem(QueueItem item) => item.status != QueueStatus.done;

bool isDoneItem(QueueItem item) => item.status == QueueStatus.done;
