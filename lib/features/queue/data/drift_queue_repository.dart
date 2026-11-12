import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/data/settings/app_settings_dao.dart';

import '../domain/queue_item.dart';
import '../domain/queue_repository.dart';

/// Repository nyata: baca `import_queue` Drift, progres via stream.
class DriftQueueRepository implements QueueRepository {
  DriftQueueRepository(this._database, {AppSettingsDao? settings})
    : _settings = settings ?? AppSettingsDao(_database);

  static const bool defaultAutoRmbg = true;

  final AppDatabase _database;
  final AppSettingsDao _settings;

  @override
  Future<List<QueueItem>> fetchQueue() async {
    final List<ImportQueueEntry> rows =
        await (_database.select(_database.importQueue)..orderBy([
              (row) => OrderingTerm.desc(row.createdAt),
              (row) => OrderingTerm.asc(row.id),
            ]))
            .get();
    return _withThumbnails(rows);
  }

  @override
  Stream<List<QueueItem>> watchQueue() {
    return (_database.select(_database.importQueue)..orderBy([
          (row) => OrderingTerm.desc(row.createdAt),
          (row) => OrderingTerm.asc(row.id),
        ]))
        .watch()
        .asyncMap(_withThumbnails);
  }

  @override
  Future<void> retryItem(String id) {
    return (_database.update(
      _database.importQueue,
    )..where((row) => row.id.equals(id))).write(
      ImportQueueCompanion(
        status: const Value(ImportStatus.pending),
        progress: const Value(0),
        errorMessage: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<bool> fetchAutoRmbg() {
    return _settings.getBool(autoRmbgSettingKey, defaultValue: defaultAutoRmbg);
  }

  @override
  Future<int> deleteItems(Iterable<String> ids) {
    final Set<String> idSet = ids.toSet();
    if (idSet.isEmpty) return Future<int>.value(0);
    return (_database.delete(
      _database.importQueue,
    )..where((row) => row.id.isIn(idSet))).go();
  }

  @override
  Future<void> setAutoRmbg(bool enabled) {
    return _settings.setBool(autoRmbgSettingKey, enabled);
  }

  /// Entri selesai memakai file stiker hasil impor (id sama dengan id stiker);
  /// entri lain memakai file sumber agar tetap ada pratinjau.
  Future<List<QueueItem>> _withThumbnails(List<ImportQueueEntry> rows) async {
    final doneIds = [
      for (final row in rows)
        if (row.status == ImportStatus.done) row.id,
    ];
    final Map<String, String> stickerPaths = {};
    if (doneIds.isNotEmpty) {
      final stickers = await (_database.select(
        _database.stickers,
      )..where((t) => t.id.isIn(doneIds))).get();
      for (final sticker in stickers) {
        stickerPaths[sticker.id] = sticker.filePath;
      }
    }
    return [
      for (final row in rows)
        _toQueueItem(row, stickerPaths[row.id] ?? row.localInputPath),
    ];
  }

  QueueItem _toQueueItem(ImportQueueEntry entry, String? thumbnailPath) {
    return QueueItem(
      id: entry.id,
      title: _titleFor(entry),
      status: _statusFor(entry.status),
      progress: entry.progress,
      sourceType: _sourceFor(entry.sourceType),
      sourceUrl: entry.sourceUrl,
      errorMessage: entry.errorMessage,
      thumbnailPath: thumbnailPath,
    );
  }

  String _titleFor(ImportQueueEntry entry) {
    final String? localPath = entry.localInputPath;
    if (localPath != null && localPath.isNotEmpty) {
      return p.basename(localPath);
    }
    final String? url = entry.sourceUrl;
    if (url != null && url.isNotEmpty) {
      final String base = p.basename(url);
      return base.isNotEmpty ? base : url;
    }
    return entry.id;
  }

  QueueStatus _statusFor(ImportStatus status) => switch (status) {
    ImportStatus.pending => QueueStatus.pending,
    ImportStatus.downloading => QueueStatus.downloading,
    ImportStatus.processing => QueueStatus.processing,
    ImportStatus.failed => QueueStatus.failed,
    ImportStatus.done => QueueStatus.done,
  };

  QueueSource _sourceFor(SourceType type) => switch (type) {
    SourceType.galleryShare => QueueSource.galleryShare,
    SourceType.galleryPicker => QueueSource.galleryPicker,
    SourceType.pinterest => QueueSource.pinterest,
    SourceType.genericUrl => QueueSource.genericUrl,
    SourceType.directImageLink => QueueSource.directImageLink,
    SourceType.manualFile => QueueSource.manualFile,
  };
}
