import 'package:crypto/crypto.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/file_system_manager.dart';
import 'package:sticker_studio/src/rust/api/encode.dart';

import 'import_exception.dart';
import 'import_processor.dart';
import 'imported_sticker_store.dart';

typedef StickerEncoder = Future<String> Function({
  required String inputPath,
  required String outputPath,
  required int targetSizeKb,
});

class StickerImportProcessor implements ImportProcessor {
  StickerImportProcessor({
    required this._stickerStore,
    required this._fileSystemManager,
    StickerEncoder? encoder,
    DateTime Function()? now,
  }) : _encoder = encoder ?? encodeWhatsappWebp,
       _now = now ?? DateTime.now;

  static const int stickerDimension = 512;
  static const int targetSizeKb = 100;

  final ImportedStickerStore _stickerStore;
  final FileSystemManager _fileSystemManager;
  final StickerEncoder _encoder;
  final DateTime Function() _now;

  @override
  Future<void> process(ImportQueueEntry entry) async {
    final inputPath = entry.localInputPath;
    if (inputPath == null) {
      throw const ImportException('File sumber tidak tersedia');
    }

    final output = _fileSystemManager.stickerFile('${entry.id}.webp');
    await _encoder(
      inputPath: inputPath,
      outputPath: output.path,
      targetSizeKb: targetSizeKb,
    );

    final bytes = await output.readAsBytes();
    await _stickerStore.save(
      StickersCompanion.insert(
        id: entry.id,
        filePath: output.path,
        thumbPath: output.path,
        width: stickerDimension,
        height: stickerDimension,
        sizeKb: (bytes.length + 1023) ~/ 1024,
        sha256: sha256.convert(bytes).toString(),
        sourceType: entry.sourceType,
        createdAt: _now(),
      ),
    );
  }
}
