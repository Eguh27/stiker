import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/app_database.dart';

import 'support/database_fixtures.dart';
import 'support/test_database.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = createTestDatabase();
    await insertPack(database, id: 'pack-1');
    await insertSticker(database, id: 'sticker-1');
  });
  tearDown(() => database.close());

  test('pasangan pack_stickers duplikat ditolak', () async {
    await insertPackSticker(database, packId: 'pack-1', stickerId: 'sticker-1');

    await expectLater(
      insertPackSticker(database, packId: 'pack-1', stickerId: 'sticker-1'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('pack_stickers menolak pack yang tidak ada', () async {
    await expectLater(
      insertPackSticker(database, packId: 'missing', stickerId: 'sticker-1'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('pack_stickers menolak sticker yang tidak ada', () async {
    await expectLater(
      insertPackSticker(database, packId: 'pack-1', stickerId: 'missing'),
      throwsA(isA<SqliteException>()),
    );
  });

  test('projects menolak sticker yang tidak ada', () async {
    await expectLater(
      database
          .into(database.projects)
          .insert(
            ProjectsCompanion.insert(
              id: 'project-1',
              stickerId: 'missing',
              projectJson: '{}',
              updatedAt: testTimestamp,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });
}
