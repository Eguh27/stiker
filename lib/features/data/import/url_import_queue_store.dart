import 'package:drift/drift.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';

class UrlImportQueueStore {
  UrlImportQueueStore(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  Future<void> insertEntry({
    required String id,
    required String sourceUrl,
    required SourceType sourceType,
    required bool autoRmbg,
  }) {
    final now = _now();
    return _database
        .into(_database.importQueue)
        .insert(
          ImportQueueCompanion.insert(
            id: id,
            sourceUrl: Value(sourceUrl),
            sourceType: sourceType,
            status: ImportStatus.pending,
            progress: 0,
            autoRmbg: autoRmbg,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<ImportQueueEntry?> fetchNextPending() {
    return (_database.select(_database.importQueue)
          ..where(
            (row) =>
                row.status.equalsValue(ImportStatus.pending) &
                row.sourceUrl.isNotNull() &
                row.localInputPath.isNull(),
          )
          ..orderBy([
            (row) => OrderingTerm.asc(row.createdAt),
            (row) => OrderingTerm.asc(row.id),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> resetInterrupted() {
    return (_database.update(_database.importQueue)..where(
          (row) =>
              row.sourceUrl.isNotNull() &
              row.status.equalsValue(ImportStatus.downloading),
        ))
        .write(
          ImportQueueCompanion(
            status: const Value(ImportStatus.pending),
            progress: const Value(0),
            errorMessage: const Value(null),
            updatedAt: Value(_now()),
          ),
        );
  }

  Future<void> markDownloading(String id) {
    return _update(
      id,
      const ImportQueueCompanion(
        status: Value(ImportStatus.downloading),
        progress: Value(10),
        errorMessage: Value(null),
      ),
    );
  }

  Future<void> markDownloaded(String id, String localInputPath) {
    return _update(
      id,
      ImportQueueCompanion(
        localInputPath: Value(localInputPath),
        status: const Value(ImportStatus.pending),
        progress: const Value(0),
        errorMessage: const Value(null),
      ),
    );
  }

  Future<void> markFailed(String id, String errorMessage) {
    return _update(
      id,
      ImportQueueCompanion(
        status: const Value(ImportStatus.failed),
        errorMessage: Value(errorMessage),
      ),
    );
  }

  Future<void> _update(String id, ImportQueueCompanion companion) {
    return (_database.update(_database.importQueue)
          ..where((row) => row.id.equals(id)))
        .write(companion.copyWith(updatedAt: Value(_now())));
  }
}
