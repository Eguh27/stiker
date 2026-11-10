import 'dart:io';

import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';

import 'import_error_message.dart';
import 'import_exception.dart';
import 'import_processor.dart';
import 'import_queue_store.dart';

class ImportQueueWatcher {
  ImportQueueWatcher({
    required this._store,
    required this._processor,
    Future<void> Function()? yieldControl,
  }) : _yieldControl = yieldControl ?? _yieldToEventLoop;

  final ImportQueueStore _store;
  final ImportProcessor _processor;
  final Future<void> Function() _yieldControl;
  Future<void>? _activeRun;

  Future<void> processPending() {
    final active = _activeRun;
    if (active != null) {
      return active;
    }

    late final Future<void> run;
    run = _drain().whenComplete(() {
      if (identical(_activeRun, run)) {
        _activeRun = null;
      }
    });
    _activeRun = run;
    return run;
  }

  Future<void> _drain() async {
    await _store.resetInterrupted();

    while (true) {
      final entry = await _store.fetchNextPending();
      if (entry == null) {
        return;
      }

      await _processEntry(entry);
      await _yieldControl();
    }
  }

  Future<void> _processEntry(ImportQueueEntry entry) async {
    try {
      await _store.updateStatus(
        entry.id,
        ImportStatus.downloading,
        progress: 10,
      );
      await _ensureOriginalExists(entry);
      await _store.updateStatus(
        entry.id,
        ImportStatus.processing,
        progress: 50,
      );
      await _processor.process(entry);
      await _store.updateStatus(entry.id, ImportStatus.done, progress: 100);
    } catch (error) {
      await _store.markFailed(entry.id, describeImportError(error));
    }
  }

  Future<void> _ensureOriginalExists(ImportQueueEntry entry) async {
    final localPath = entry.localInputPath;
    if (localPath == null || !await File(localPath).exists()) {
      throw const ImportException('File sumber tidak ditemukan');
    }
  }

  static Future<void> _yieldToEventLoop() {
    return Future<void>.delayed(Duration.zero);
  }
}
