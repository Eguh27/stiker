import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';

import 'test_database.dart';

Future<void> insertSticker(
  AppDatabase database, {
  required String id,
  SourceType sourceType = SourceType.manualFile,
}) {
  return database
      .into(database.stickers)
      .insert(
        StickersCompanion.insert(
          id: id,
          filePath: '/originals/$id.webp',
          thumbPath: '/thumbs/$id.webp',
          width: 512,
          height: 512,
          sizeKb: 42,
          sha256: 'sha-$id',
          sourceType: sourceType,
          createdAt: testTimestamp,
        ),
      );
}

Future<void> insertImportQueueEntry(
  AppDatabase database, {
  required String id,
  required ImportStatus status,
}) {
  return database
      .into(database.importQueue)
      .insert(
        ImportQueueCompanion.insert(
          id: id,
          sourceType: SourceType.manualFile,
          status: status,
          progress: 0,
          autoRmbg: false,
          createdAt: testTimestamp,
          updatedAt: testTimestamp,
        ),
      );
}

Future<void> insertPack(AppDatabase database, {required String id}) {
  return database
      .into(database.packs)
      .insert(
        PacksCompanion.insert(
          id: id,
          name: 'Pack $id',
          author: 'Sticker Studio',
          trayIconPath: '/tray-$id.webp',
          version: '1',
          isSynced: false,
          createdAt: testTimestamp,
          updatedAt: testTimestamp,
        ),
      );
}

Future<void> insertPackSticker(
  AppDatabase database, {
  required String packId,
  required String stickerId,
}) {
  return database
      .into(database.packStickers)
      .insert(
        PackStickersCompanion.insert(
          packId: packId,
          stickerId: stickerId,
          position: 0,
        ),
      );
}

Future<void> insertRawSticker(AppDatabase database, String sourceType) {
  return database.customStatement(
    'INSERT INTO stickers '
    '(id, file_path, thumb_path, width, height, size_kb, sha256, '
    'source_type, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    ['raw', '/f', '/t', 1, 1, 1, 'sha', sourceType, 0],
  );
}

Future<void> insertRawImportQueueEntry(AppDatabase database, String status) {
  return database.customStatement(
    'INSERT INTO import_queue '
    '(id, source_type, status, progress, auto_rmbg, created_at, updated_at) '
    'VALUES (?, ?, ?, ?, ?, ?, ?)',
    ['raw', 'MANUAL_FILE', status, 0, 0, 0, 0],
  );
}
