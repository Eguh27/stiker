import 'package:drift/drift.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';

@DataClassName('Sticker')
class Stickers extends Table {
  TextColumn get id => text()();
  TextColumn get filePath => text()();
  TextColumn get thumbPath => text()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  IntColumn get sizeKb => integer()();
  TextColumn get sha256 => text()();
  TextColumn get sourceType => text().map(const SourceTypeConverter())();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (source_type IN ('GALLERY_SHARE', 'GALLERY_PICKER', "
        "'PINTEREST', 'GENERIC_URL', 'DIRECT_IMAGE_LINK', 'MANUAL_FILE'))",
  ];
}
