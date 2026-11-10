import 'package:drift/drift.dart';
import 'package:sticker_studio/features/data/database/tables/stickers.dart';

@DataClassName('Project')
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get stickerId => text().references(Stickers, #id)();
  TextColumn get projectJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
