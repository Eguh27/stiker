import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/data/file_system_manager.dart';

import 'import_error_message.dart';
import 'import_id.dart';
import 'import_queue_store.dart';

class BulkImportRepository {
  BulkImportRepository({
    required this._store,
    required this._fileSystemManager,
    String Function()? createId,
  }) : _createId = createId ?? createImportId;

  final ImportQueueStore _store;
  final FileSystemManager _fileSystemManager;
  final String Function() _createId;

  Future<List<String>> enqueueFiles({
    required Iterable<String> inputPaths,
    required SourceType sourceType,
    bool autoRmbg = false,
  }) async {
    final ids = <String>[];

    for (final inputPath in inputPaths) {
      final id = _createId();
      ids.add(id);
      await _enqueueFile(
        id: id,
        inputPath: inputPath,
        sourceType: sourceType,
        autoRmbg: autoRmbg,
      );
      await Future<void>.delayed(Duration.zero);
    }

    return ids;
  }

  Future<void> _enqueueFile({
    required String id,
    required String inputPath,
    required SourceType sourceType,
    required bool autoRmbg,
  }) async {
    final extension = p.extension(inputPath).toLowerCase();
    final destination = _fileSystemManager.originalFile('$id$extension');

    try {
      await File(inputPath).copy(destination.path);
      await _store.insertEntry(
        id: id,
        localInputPath: destination.path,
        sourceType: sourceType,
        status: ImportStatus.pending,
        autoRmbg: autoRmbg,
      );
    } catch (error) {
      await _store.insertEntry(
        id: id,
        localInputPath: null,
        sourceType: sourceType,
        status: ImportStatus.failed,
        autoRmbg: autoRmbg,
        errorMessage: describeImportError(error),
      );
    }
  }
}
