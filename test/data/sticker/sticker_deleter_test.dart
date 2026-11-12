import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/data/sticker/sticker_deleter.dart';

import '../support/test_database.dart';

void main() {
  late AppDatabase database;
  late Directory tempDir;
  late StickerDeleter deleter;

  setUp(() {
    database = createTestDatabase();
    tempDir = Directory.systemTemp.createTempSync('sticker_deleter_');
    deleter = StickerDeleter(database);
  });

  tearDown(() async {
    await database.close();
    tempDir.deleteSync(recursive: true);
  });

  String makeFile(String name) =>
      (File('${tempDir.path}/$name')..writeAsStringSync('x')).path;

  Future<void> addSticker(String id) {
    final path = makeFile('$id.webp');
    return database
        .into(database.stickers)
        .insert(
          StickersCompanion.insert(
            id: id,
            filePath: path,
            thumbPath: path,
            width: 512,
            height: 512,
            sizeKb: 10,
            sha256: id,
            sourceType: SourceType.manualFile,
            createdAt: DateTime(2026, 11, 11),
          ),
        );
  }

  Future<void> addPack(String id, List<String> stickerIds, String tray) async {
    final now = DateTime(2026, 11, 11);
    await database
        .into(database.packs)
        .insert(
          PacksCompanion.insert(
            id: id,
            name: id,
            author: 'Tester',
            trayIconPath: tray,
            version: '1',
            isSynced: true,
            createdAt: now,
            updatedAt: now,
          ),
        );
    for (var i = 0; i < stickerIds.length; i++) {
      await database
          .into(database.packStickers)
          .insert(
            PackStickersCompanion.insert(
              packId: id,
              stickerId: stickerIds[i],
              position: i,
            ),
          );
    }
  }

  test('menghapus baris, relasi pack, project, antrean, dan file', () async {
    await addSticker('a');
    await addSticker('b');
    await addSticker('c');
    final trayOfA = (await (database.select(database.stickers)
          ..where((t) => t.id.equals('a'))).getSingle()).filePath;
    await addPack('pack1', ['a', 'b', 'c'], trayOfA);
    await database
        .into(database.projects)
        .insert(
          ProjectsCompanion.insert(
            id: 'p-a',
            stickerId: 'a',
            projectJson: '{}',
            updatedAt: DateTime(2026, 11, 11),
          ),
        );
    final fileOfA = File(trayOfA);

    final removed = await deleter.delete(['a']);

    expect(removed, 1);
    expect(fileOfA.existsSync(), isFalse);
    expect(await database.select(database.stickers).get(), hasLength(2));
    expect(await database.select(database.projects).get(), isEmpty);

    final rows = await (database.select(database.packStickers)
          ..orderBy([(t) => OrderingTerm.asc(t.position)])).get();
    expect([for (final r in rows) r.stickerId], ['b', 'c']);
    expect([for (final r in rows) r.position], [0, 1]);

    final pack = await database.select(database.packs).getSingle();
    expect(pack.isSynced, isFalse);
    expect(pack.trayIconPath, isNot(trayOfA));
    expect(pack.trayIconPath, isNotEmpty);
  });

  test('id yang tidak ada diabaikan dan mengembalikan 0', () async {
    expect(await deleter.delete(['tidak-ada']), 0);
    expect(await deleter.delete(const []), 0);
  });
}
