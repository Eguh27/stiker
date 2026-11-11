import 'package:flutter/foundation.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/file_system_manager.dart';

import 'import_processor.dart';
import 'source_pack_assigner.dart';

/// Membungkus processor stiker: setelah stiker tersimpan, masukkan ke pack
/// sumbernya lalu beri tahu UI agar daftar dimuat ulang.
class PackAssigningProcessor implements ImportProcessor {
  PackAssigningProcessor({
    required this.inner,
    required this.assigner,
    required this.fileSystemManager,
    this.onStickerAdded,
  });

  final ImportProcessor inner;
  final SourcePackAssigner assigner;
  final FileSystemManager fileSystemManager;
  final VoidCallback? onStickerAdded;

  @override
  Future<void> process(ImportQueueEntry entry) async {
    await inner.process(entry);
    final stickerPath = fileSystemManager.stickerFile('${entry.id}.webp').path;
    await assigner.assign(entry, stickerPath);
    onStickerAdded?.call();
  }
}
