import 'package:drift/drift.dart';

import '../app_database.dart' hide Sticker;
import '../database/database_enums.dart';
import '../../library/domain/sticker.dart';
import '../../library/domain/sticker_repository.dart';
import 'sticker_row_mapper.dart';

/// Implementasi SQLite Drift untuk StickerRepository.
class DriftStickerRepository implements StickerRepository {
  DriftStickerRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<Sticker>> fetchStickers() async {
    final rows = await (_database.select(
      _database.stickers,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

    return rows.map(stickerFromRow).toList();
  }

  Future<void> addSticker({
    required String id,
    required String filePath,
    required String thumbPath,
    required SourceType sourceType,
    int width = 512,
    int height = 512,
    int sizeKb = 50,
  }) async {
    await _database
        .into(_database.stickers)
        .insertOnConflictUpdate(
          StickersCompanion.insert(
            id: id,
            filePath: filePath,
            thumbPath: thumbPath,
            width: width,
            height: height,
            sizeKb: sizeKb,
            sha256: 'sha-$id',
            sourceType: sourceType,
            createdAt: DateTime.now(),
          ),
        );
  }
}
