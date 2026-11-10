import 'package:drift/drift.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';

class ImportQueueStore {
  ImportQueueStore(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  Future<void> insertEntry({
    required String id,
    required String? localInputPath,
    required SourceType sourceType,
    required ImportStatus status,
    required bool autoRmbg,
    int progress = 0,
    String? errorMessage,
  }) {
    final now = _now();

    return _database
        .into(_database.importQueue)
        .insert(
          ImportQueueCompanion.insert(
            id: id,
            localInputPath: Value(localInputPath),
            sourceType: sourceType,
            status: status,
            progress: progress,
            errorMessage: Value(errorMessage),
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
                row.localInputPath.isNotNull(),
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
              row.localInputPath.isNotNull() &
              row.status.isInValues(const [
                ImportStatus.downloading,
                ImportStatus.processing,
              ]),
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

  Future<void> updateStatus(
    String id,
    ImportStatus status, {
    required int progress,
    String? errorMessage,
  }) {
    return (_database.update(
      _database.importQueue,
    )..where((row) => row.id.equals(id))).write(
      ImportQueueCompanion(
        status: Value(status),
        progress: Value(progress),
        errorMessage: Value(errorMessage),
        updatedAt: Value(_now()),
      ),
    );
  }

  Future<void> markFailed(String id, String errorMessage) {
    return (_database.update(
      _database.importQueue,
    )..where((row) => row.id.equals(id))).write(
      ImportQueueCompanion(
        status: const Value(ImportStatus.failed),
        errorMessage: Value(errorMessage),
        updatedAt: Value(_now()),
      ),
    );
  }
}
