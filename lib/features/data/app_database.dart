import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/data/database/tables/app_settings.dart';
import 'package:sticker_studio/features/data/database/tables/import_queue.dart';
import 'package:sticker_studio/features/data/database/tables/pack_stickers.dart';
import 'package:sticker_studio/features/data/database/tables/packs.dart';
import 'package:sticker_studio/features/data/database/tables/projects.dart';
import 'package:sticker_studio/features/data/database/tables/stickers.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Packs, Stickers, PackStickers, ImportQueue, Projects, AppSettings],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  static const int currentSchemaVersion = 3;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2 && to >= 2) {
        await migrator.createTable(appSettings);
      }
      if (from < 3 && to >= 3) {
        await migrator.addColumn(packs, packs.emojis);
      }
    },
  );
}

QueryExecutor openAppDatabase(File file) {
  return NativeDatabase.createInBackground(
    file,
    setup: (database) {
      database.execute('PRAGMA journal_mode = WAL;');
      database.execute('PRAGMA busy_timeout = 5000;');
      database.execute('PRAGMA foreign_keys = ON;');
    },
  );
}
