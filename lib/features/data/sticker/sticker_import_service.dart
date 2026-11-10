import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/src/rust/api/encode.dart';

import 'drift_sticker_repository.dart';

class StickerImportService {
  StickerImportService(this._repository, {ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final DriftStickerRepository _repository;
  final ImagePicker _picker;

  Future<int> importFromGallery() async {
    final List<XFile> picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return 0;

    final appDir = await getApplicationDocumentsDirectory();
    final stickersDir = Directory('${appDir.path}/stickers');
    final originalsDir = Directory('${appDir.path}/originals');

    if (!stickersDir.existsSync()) stickersDir.createSync(recursive: true);
    if (!originalsDir.existsSync()) originalsDir.createSync(recursive: true);

    var count = 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0; i < picked.length; i++) {
      final id = 'stk-$now-$i';
      final srcFile = File(picked[i].path);
      final origPath = '${originalsDir.path}/$id.png';
      final stickerPath = '${stickersDir.path}/$id.webp';

      await srcFile.copy(origPath);

      try {
        await encodeWhatsappWebp(
          inputPath: origPath,
          outputPath: stickerPath,
          targetSizeKb: 100,
        );
      } catch (_) {
        await srcFile.copy(stickerPath);
      }

      await _repository.addSticker(
        id: id,
        filePath: stickerPath,
        thumbPath: stickerPath,
        sourceType: SourceType.galleryPicker,
      );
      count++;
    }
    return count;
  }
}
