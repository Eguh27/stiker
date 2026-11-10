import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';

import 'support/database_fixtures.dart';
import 'support/test_database.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = createTestDatabase());
  tearDown(() => database.close());

  test('semua SourceType dapat disimpan dan dibaca kembali', () async {
    for (final sourceType in SourceType.values) {
      await insertSticker(
        database,
        id: sourceType.databaseValue,
        sourceType: sourceType,
      );
    }

    final stored = await database.select(database.stickers).get();

    expect(
      stored.map((sticker) => sticker.sourceType),
      unorderedEquals(SourceType.values),
    );
  });

  test('source_type di luar enum ditolak database', () async {
    await expectLater(
      insertRawSticker(database, 'UNKNOWN'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('semua ImportStatus dapat disimpan dan dibaca kembali', () async {
    for (final status in ImportStatus.values) {
      await insertImportQueueEntry(
        database,
        id: status.databaseValue,
        status: status,
      );
    }

    final stored = await database.select(database.importQueue).get();

    expect(
      stored.map((entry) => entry.status),
      unorderedEquals(ImportStatus.values),
    );
  });

  test('status di luar enum ditolak database', () async {
    await expectLater(
      insertRawImportQueueEntry(database, 'UNKNOWN'),
      throwsA(isA<SqliteException>()),
    );
  });
}
