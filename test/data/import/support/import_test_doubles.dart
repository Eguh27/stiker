import 'dart:io';

import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/data/import/import_processor.dart';
import 'package:sticker_studio/features/data/import/import_queue_store.dart';

class RecordingImportQueueStore extends ImportQueueStore {
  RecordingImportQueueStore(super.database);

  final List<ImportStatus> transitions = [];
  int resetCount = 0;

  @override
  Future<int> resetInterrupted() {
    resetCount++;
    return super.resetInterrupted();
  }

  @override
  Future<void> updateStatus(
    String id,
    ImportStatus status, {
    required int progress,
    String? errorMessage,
  }) {
    transitions.add(status);
    return super.updateStatus(
      id,
      status,
      progress: progress,
      errorMessage: errorMessage,
    );
  }
}

class FakeImportProcessor implements ImportProcessor {
  FakeImportProcessor({this.onProcess});

  final Future<void> Function(ImportQueueEntry entry)? onProcess;
  final List<String> processedIds = [];

  @override
  Future<void> process(ImportQueueEntry entry) async {
    processedIds.add(entry.id);
    await onProcess?.call(entry);
  }
}

class FakeStickerEncoder {
  FakeStickerEncoder({this.payload = const [1, 2, 3], this.error});

  final List<int> payload;
  final Object? error;
  String? inputPath;
  String? outputPath;
  int? targetSizeKb;

  Future<String> call({
    required String inputPath,
    required String outputPath,
    required int targetSizeKb,
  }) async {
    this.inputPath = inputPath;
    this.outputPath = outputPath;
    this.targetSizeKb = targetSizeKb;
    if (error != null) {
      throw error!;
    }
    await File(outputPath).writeAsBytes(payload);
    return outputPath;
  }
}
