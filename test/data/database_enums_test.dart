import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';

void main() {
  group('SourceType', () {
    test('nilai database sesuai kontrak', () {
      expect(SourceType.values.map((type) => type.databaseValue), [
        'GALLERY_SHARE',
        'GALLERY_PICKER',
        'PINTEREST',
        'GENERIC_URL',
        'DIRECT_IMAGE_LINK',
        'MANUAL_FILE',
      ]);
    });

    test('converter bolak-balik tanpa kehilangan nilai', () {
      const converter = SourceTypeConverter();
      for (final type in SourceType.values) {
        expect(converter.fromSql(converter.toSql(type)), type);
      }
    });

    test('menolak nilai di luar kontrak', () {
      expect(() => SourceType.fromDatabase('UNKNOWN'), throwsArgumentError);
    });
  });

  group('ImportStatus', () {
    test('nilai database sesuai kontrak', () {
      expect(ImportStatus.values.map((status) => status.databaseValue), [
        'PENDING',
        'DOWNLOADING',
        'PROCESSING',
        'FAILED',
        'DONE',
      ]);
    });

    test('converter bolak-balik tanpa kehilangan nilai', () {
      const converter = ImportStatusConverter();
      for (final status in ImportStatus.values) {
        expect(converter.fromSql(converter.toSql(status)), status);
      }
    });

    test('menolak nilai di luar kontrak', () {
      expect(() => ImportStatus.fromDatabase('UNKNOWN'), throwsArgumentError);
    });
  });
}
