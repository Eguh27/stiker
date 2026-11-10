import 'package:drift/native.dart';
import 'package:sticker_studio/features/data/app_database.dart';

AppDatabase createTestDatabase() {
  return AppDatabase(
    NativeDatabase.memory(
      setup: (database) {
        database.execute('PRAGMA busy_timeout = 5000;');
        database.execute('PRAGMA foreign_keys = ON;');
      },
    ),
  );
}

final DateTime testTimestamp = DateTime.utc(2026, 11, 9);
