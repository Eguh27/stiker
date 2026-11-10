import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/pack/pack_repository_impl.dart';

import '../../support/database_fixtures.dart';
import '../../support/test_database.dart';

class PackWorkspace {
  PackWorkspace._(this.database, this.repository);

  final AppDatabase database;
  final PackRepositoryImpl repository;

  static Future<PackWorkspace> create({int stickerCount = 30}) async {
    final AppDatabase database = createTestDatabase();
    for (int index = 1; index <= stickerCount; index++) {
      await insertSticker(database, id: 'sticker-$index');
    }
    return PackWorkspace._(
      database,
      PackRepositoryImpl(database, now: () => DateTime.utc(2026, 11, 10)),
    );
  }

  List<String> stickerIds(int count, {int from = 1}) {
    return [
      for (int index = 0; index < count; index++) 'sticker-${from + index}',
    ];
  }

  Future<void> dispose() => database.close();
}
