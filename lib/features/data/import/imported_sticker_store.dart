import 'package:sticker_studio/features/data/app_database.dart';

class ImportedStickerStore {
  ImportedStickerStore(this._database);

  final AppDatabase _database;

  Future<void> save(StickersCompanion sticker) {
    return _database.into(_database.stickers).insertOnConflictUpdate(sticker);
  }
}
