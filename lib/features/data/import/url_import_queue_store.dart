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

  /// Ambil baris PENDING berikutnya dan tandai DOWNLOADING dalam satu UPDATE
  /// atomik, supaya foreground runner dan WorkManager tidak memproses baris sama.
  Future<ImportQueueEntry?> claimNextPending() async {
    while (true) {
      final entry = await fetchNextPending();
      if (entry == null) return null;
      final claimed =
          await (_database.update(_database.importQueue)..where(
                (row) =>
                    row.id.equals(entry.id) &
                    row.status.equalsValue(ImportStatus.pending),
              ))
              .write(
                ImportQueueCompanion(
                  status: const Value(ImportStatus.downloading),
                  progress: const Value(10),
                  errorMessage: const Value(null),
                  updatedAt: Value(_now()),
                ),
              );
      if (claimed == 1) return entry;
    }
  }

  /// Kembalikan unduhan terputus ke PENDING. Dengan [olderThan], hanya baris
  /// yang sudah lama tidak berubah, agar unduhan runner lain tidak ikut di-reset.
  Future<int> resetInterrupted({Duration? olderThan}) {
    return (_database.update(_database.importQueue)..where((row) {
          final interrupted =
              row.sourceUrl.isNotNull() &
              row.status.equalsValue(ImportStatus.downloading);
          if (olderThan == null) return interrupted;
          return interrupted &
              row.updatedAt.isSmallerOrEqualValue(_now().subtract(olderThan));
        }))
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
