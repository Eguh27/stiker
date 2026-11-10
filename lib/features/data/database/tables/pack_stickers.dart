import 'package:drift/drift.dart';
import 'package:sticker_studio/features/data/database/tables/packs.dart';
import 'package:sticker_studio/features/data/database/tables/stickers.dart';

@DataClassName('PackSticker')
class PackStickers extends Table {
  TextColumn get packId => text().references(Packs, #id)();
  TextColumn get stickerId => text().references(Stickers, #id)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {packId, stickerId};
}
