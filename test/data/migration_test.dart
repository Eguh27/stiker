import 'dart:io';

import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sticker_studio/features/data/app_database.dart';

import 'generated/schema.dart';

void main() {
  group('database baru', () {
    late Directory temporaryDirectory;
    late AppDatabase database;

    setUp(() async {
      temporaryDirectory = await Directory.systemTemp.createTemp(
        'sticker_studio_migration_',
      );
      database = AppDatabase(
        openAppDatabase(File(p.join(temporaryDirectory.path, 'app.sqlite'))),
      );
    });

    tearDown(() async {
      await database.close();
      await temporaryDirectory.delete(recursive: true);
    });

    test('onCreate membuat skema terbaru dan menulis user_version', () async {
      final version = await database
          .customSelect('PRAGMA user_version')
          .getSingle()
          .then((row) => row.read<int>('user_version'));

      expect(version, AppDatabase.currentSchemaVersion);
      await database.validateDatabaseSchema();
    });
  });

  test('snapshot skema terbaru cocok dengan kode saat ini', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final connection = await verifier.startAt(AppDatabase.currentSchemaVersion);
    final database = AppDatabase(connection);

    await verifier.migrateAndValidate(
      database,
      AppDatabase.currentSchemaVersion,
    );
    await database.close();
  });

  test('migrasi v1 -> v2 menambah app_settings tanpa kehilangan data', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final schema = await verifier.schemaAt(1);
    schema.rawDatabase.execute(
      'INSERT INTO packs '
      '(id, name, author, tray_icon_path, version, is_synced, '
      'created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      ['old-pack', 'Pack Lama', 'Author', '/tray.webp', '4', 1, 0, 0],
    );
    schema.rawDatabase.execute(
      'INSERT INTO import_queue '
      '(id, source_type, status, progress, auto_rmbg, created_at, updated_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?)',
      ['old-queue', 'MANUAL_FILE', 'FAILED', 0, 0, 0, 0],
    );

    final database = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(database, 2);

    final pack = await database
        .customSelect('SELECT name, version, is_synced FROM packs')
        .getSingle();
    expect(pack.read<String>('name'), 'Pack Lama');
    expect(pack.read<String>('version'), '4');
    expect(pack.read<bool>('is_synced'), isTrue);
    final queue = await database
        .customSelect('SELECT id FROM import_queue')
        .getSingle();
    expect(queue.read<String>('id'), 'old-queue');
    final settings = await database
        .customSelect('SELECT * FROM app_settings')
        .get();
    expect(settings, isEmpty);
    await database.close();
  });

  test(
    'migrasi v2 -> v3 menambah packs.emojis tanpa kehilangan data',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(2);
      schema.rawDatabase.execute(
        'INSERT INTO packs '
        '(id, name, author, tray_icon_path, version, is_synced, '
        'created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        ['v2-pack', 'Pack V2', 'Author', '/tray.webp', '2', 1, 0, 0],
      );

      final database = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(database, 3);

      final pack = await database.select(database.packs).getSingle();
      expect(pack.name, 'Pack V2');
      expect(pack.version, '2');
      expect(pack.isSynced, isTrue);
      expect(pack.emojis, '[]');
      await database.close();
    },
  );
}
