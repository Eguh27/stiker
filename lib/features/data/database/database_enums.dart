import 'package:drift/drift.dart';

enum SourceType {
  galleryShare('GALLERY_SHARE'),
  galleryPicker('GALLERY_PICKER'),
  pinterest('PINTEREST'),
  genericUrl('GENERIC_URL'),
  directImageLink('DIRECT_IMAGE_LINK'),
  manualFile('MANUAL_FILE');

  const SourceType(this.databaseValue);

  final String databaseValue;

  static SourceType fromDatabase(String value) {
    return values.firstWhere(
      (type) => type.databaseValue == value,
      orElse: () =>
          throw ArgumentError.value(value, 'value', 'Unknown source_type'),
    );
  }
}

enum ImportStatus {
  pending('PENDING'),
  downloading('DOWNLOADING'),
  processing('PROCESSING'),
  failed('FAILED'),
  done('DONE');

  const ImportStatus(this.databaseValue);

  final String databaseValue;

  static ImportStatus fromDatabase(String value) {
    return values.firstWhere(
      (status) => status.databaseValue == value,
      orElse: () => throw ArgumentError.value(value, 'value', 'Unknown status'),
    );
  }
}

class SourceTypeConverter extends TypeConverter<SourceType, String> {
  const SourceTypeConverter();

  @override
  SourceType fromSql(String fromDb) => SourceType.fromDatabase(fromDb);

  @override
  String toSql(SourceType value) => value.databaseValue;
}

class ImportStatusConverter extends TypeConverter<ImportStatus, String> {
  const ImportStatusConverter();

  @override
  ImportStatus fromSql(String fromDb) => ImportStatus.fromDatabase(fromDb);

  @override
  String toSql(ImportStatus value) => value.databaseValue;
}
