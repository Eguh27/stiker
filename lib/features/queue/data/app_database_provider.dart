import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_studio/features/data/app_database.dart';

/// DB nyata untuk Queue Monitor. File-backed + `processPending` cakupan
/// task integrasi HP; host-only pakai in-memory Drift (tabel nyata).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final AppDatabase database = AppDatabase(
    NativeDatabase.memory(
      setup: (database) {
        database.execute('PRAGMA busy_timeout = 5000;');
        database.execute('PRAGMA foreign_keys = ON;');
      },
    ),
  );
  ref.onDispose(database.close);
  return database;
});
