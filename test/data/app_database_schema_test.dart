import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/app_database.dart';

import 'support/expected_schema.dart';
import 'support/test_database.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = createTestDatabase());
  tearDown(() => database.close());

  test('database berisi tepat enam tabel kontrak', () async {
    final rows = await database
        .customSelect(
          "SELECT name FROM sqlite_master "
          "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
        )
        .get();

    expect(rows.map((row) => row.read<String>('name')), [
      'app_settings',
      'import_queue',
      'pack_stickers',
      'packs',
      'projects',
      'stickers',
    ]);
  });

  for (final entry in expectedColumnTypes.entries) {
    test('kolom tabel ${entry.key} sesuai kontrak', () async {
      final rows = await database
          .customSelect('PRAGMA table_info(${entry.key})')
          .get();
      final actual = {
        for (final row in rows)
          row.read<String>('name'): row.read<String>('type'),
      };

      expect(actual, entry.value);
    });
  }

  test('primary key sesuai kontrak', () async {
    expect(await _primaryKey(database, 'packs'), ['id']);
    expect(await _primaryKey(database, 'stickers'), ['id']);
    expect(await _primaryKey(database, 'pack_stickers'), [
      'pack_id',
      'sticker_id',
    ]);
    expect(await _primaryKey(database, 'import_queue'), ['id']);
    expect(await _primaryKey(database, 'projects'), ['id']);
    expect(await _primaryKey(database, 'app_settings'), ['key']);
  });

  test('kolom opsional import_queue boleh NULL', () async {
    final columns = await _columnInfo(database, 'import_queue');

    expect(columns['source_url']?['notnull'], 0);
    expect(columns['local_input_path']?['notnull'], 0);
    expect(columns['error_message']?['notnull'], 0);
    expect(columns['status']?['notnull'], 1);
  });
}

Future<List<String>> _primaryKey(AppDatabase database, String table) async {
  final columns = await _columnInfo(database, table);
  final keyed =
      columns.entries.where((entry) => (entry.value['pk'] as int) > 0).toList()
        ..sort(
          (a, b) => (a.value['pk'] as int).compareTo(b.value['pk'] as int),
        );

  return [for (final entry in keyed) entry.key];
}

Future<Map<String, Map<String, Object?>>> _columnInfo(
  AppDatabase database,
  String table,
) async {
  final rows = await database.customSelect('PRAGMA table_info($table)').get();
  return {for (final row in rows) row.read<String>('name'): row.data};
}
