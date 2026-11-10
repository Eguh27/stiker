import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sticker_studio/features/data/app_database.dart';

void main() {
  late Directory temporaryDirectory;
  late AppDatabase database;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'sticker_studio_database_',
    );
    database = AppDatabase(
      openAppDatabase(File(p.join(temporaryDirectory.path, 'app.sqlite'))),
    );
    await database.customSelect('SELECT 1').get();
  });

  tearDown(() async {
    await database.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('WAL aktif pada database file', () async {
    final row = await database.customSelect('PRAGMA journal_mode').getSingle();

    expect(row.read<String>('journal_mode'), 'wal');
  });

  test('busy_timeout bernilai 5000 ms', () async {
    final row = await database.customSelect('PRAGMA busy_timeout').getSingle();

    expect(row.read<int>('timeout'), 5000);
  });

  test('foreign key constraint aktif', () async {
    final row = await database.customSelect('PRAGMA foreign_keys').getSingle();

    expect(row.read<int>('foreign_keys'), 1);
  });
}
