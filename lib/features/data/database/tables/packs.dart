import 'package:drift/drift.dart';

@DataClassName('Pack')
class Packs extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get author => text()();
  TextColumn get trayIconPath => text()();
  TextColumn get version => text()();
  BoolColumn get isSynced => boolean()();
  TextColumn get emojis => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
