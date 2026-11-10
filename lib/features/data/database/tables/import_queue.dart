import 'package:drift/drift.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';

@DataClassName('ImportQueueEntry')
class ImportQueue extends Table {
  TextColumn get id => text()();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get localInputPath => text().nullable()();
  TextColumn get sourceType => text().map(const SourceTypeConverter())();
  TextColumn get status => text().map(const ImportStatusConverter())();
  IntColumn get progress => integer()();
  TextColumn get errorMessage => text().nullable()();
  BoolColumn get autoRmbg => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (source_type IN ('GALLERY_SHARE', 'GALLERY_PICKER', "
        "'PINTEREST', 'GENERIC_URL', 'DIRECT_IMAGE_LINK', 'MANUAL_FILE'))",
    "CHECK (status IN ('PENDING', 'DOWNLOADING', 'PROCESSING', "
        "'FAILED', 'DONE'))",
  ];
}
