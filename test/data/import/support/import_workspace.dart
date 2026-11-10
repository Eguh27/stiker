import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/file_system_manager.dart';
import 'package:sticker_studio/features/data/import/bulk_import_repository.dart';
import 'package:sticker_studio/features/data/import/import_queue_store.dart';
import 'package:sticker_studio/features/data/import/imported_sticker_store.dart';

import '../../support/test_database.dart';

class ImportWorkspace {
  ImportWorkspace._({
    required this.rootDirectory,
    required this.database,
    required this.fileSystemManager,
    required this.queueStore,
    required this.stickerStore,
  }) : repository = BulkImportRepository(
         store: queueStore,
         fileSystemManager: fileSystemManager,
       );

  final Directory rootDirectory;
  final AppDatabase database;
  final FileSystemManager fileSystemManager;
  final ImportQueueStore queueStore;
  final ImportedStickerStore stickerStore;
  final BulkImportRepository repository;

  static Future<ImportWorkspace> create({
    ImportQueueStore Function(AppDatabase database)? createQueueStore,
  }) async {
    final root = await Directory.systemTemp.createTemp('sticker_import_');
    final database = createTestDatabase();
    final fileSystemManager = await FileSystemManager.initialize(
      baseDirectory: root,
    );

    return ImportWorkspace._(
      rootDirectory: root,
      database: database,
      fileSystemManager: fileSystemManager,
      queueStore:
          createQueueStore?.call(database) ?? ImportQueueStore(database),
      stickerStore: ImportedStickerStore(database),
    );
  }

  Future<File> createInput(
    String name, {
    List<int> bytes = const [1, 2, 3, 4],
  }) async {
    final file = File(p.join(rootDirectory.path, 'input', name));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<List<ImportQueueEntry>> fetchQueueRows() {
    return database.select(database.importQueue).get();
  }

  Future<Sticker?> fetchSticker(String id) {
    return (database.select(
      database.stickers,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
  }

  Future<void> dispose() async {
    await database.close();
    await rootDirectory.delete(recursive: true);
  }
}
