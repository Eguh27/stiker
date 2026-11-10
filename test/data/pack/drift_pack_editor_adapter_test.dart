import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sticker_studio/features/data/app_database.dart' hide Sticker;
import 'package:sticker_studio/features/data/pack/drift_pack_editor_adapter.dart';
import 'package:sticker_studio/features/library/domain/sticker.dart';
import 'package:sticker_studio/features/packs/domain/pack_repository.dart';
import 'package:sticker_studio/features/packs/domain/sticker_pack.dart';
import 'package:sticker_studio/features/packs/presentation/pack_providers.dart';
import 'package:sticker_studio/features/queue/data/app_database_provider.dart';

import '../support/test_database.dart';

List<Sticker> _dummyStickers(int count) {
  return [
    for (int i = 1; i <= count; i++)
      Sticker(
        id: 'stk-$i',
        label: 'Stiker $i',
        colorKind: StickerColorKind.lavender,
        shape: StickerShape.blob,
      ),
  ];
}

void main() {
  group('DriftPackEditorAdapter', () {
    late AppDatabase database;
    late DriftPackEditorAdapter adapter;

    setUp(() {
      database = createTestDatabase();
      adapter = DriftPackEditorAdapter(database);
    });

    tearDown(() => database.close());

    test('createPack menyimpan pack, stiker, dan emoji tags ke DB', () async {
      final stickers = _dummyStickers(3);
      final PackDetail created = await adapter.createPack(
        name: 'Meme Pack',
        author: 'Budi',
        stickers: stickers,
        emojiTags: ['Smile', 'Party'],
      );

      expect(created.pack.name, 'Meme Pack');
      expect(created.pack.author, 'Budi');
      expect(created.pack.stickerCount, 3);
      expect(created.emojiTags, ['Smile', 'Party']);

      final List<StickerPack> list = await adapter.fetchPacks();
      expect(list, hasLength(1));
      expect(list.first.name, 'Meme Pack');

      final PackDetail detail = await adapter.fetchPackDetail(created.pack.id);
      expect(detail.pack.name, 'Meme Pack');
      expect(detail.stickers.map((s) => s.id), ['stk-1', 'stk-2', 'stk-3']);
      expect(detail.emojiTags, ['Smile', 'Party']);
    });

    test(
      'updatePack dan reorderStickers mengubah metadata dan urutan',
      () async {
        final stickers = _dummyStickers(4);
        final PackDetail created = await adapter.createPack(
          name: 'Awal',
          author: 'Penulis',
          stickers: stickers,
          emojiTags: ['Smile'],
        );

        await adapter.updatePack(
          packId: created.pack.id,
          name: 'Revisi',
          author: 'Penulis Baru',
          emojiTags: ['Love', 'Party'],
        );

        await adapter.reorderStickers(
          packId: created.pack.id,
          stickerIds: ['stk-4', 'stk-2', 'stk-3', 'stk-1'],
        );

        final PackDetail updated = await adapter.fetchPackDetail(
          created.pack.id,
        );
        expect(updated.pack.name, 'Revisi');
        expect(updated.pack.author, 'Penulis Baru');
        expect(updated.emojiTags, ['Love', 'Party']);
        expect(updated.stickers.map((s) => s.id), [
          'stk-4',
          'stk-2',
          'stk-3',
          'stk-1',
        ]);
      },
    );

    test('data pack + urutan + emoji tetap utuh setelah DB ditutup dan dibuka ulang', () async {
      final tempDir = await Directory.systemTemp.createTemp('adapter_test_');
      final dbFile = File(p.join(tempDir.path, 'app.sqlite'));

      final db1 = AppDatabase(openAppDatabase(dbFile));
      final adapter1 = DriftPackEditorAdapter(db1);

      final created = await adapter1.createPack(
        name: 'Persistent Pack',
        author: 'Persist Author',
        stickers: _dummyStickers(3),
        emojiTags: ['Smile', 'Work'],
      );
      await db1.close();

      final db2 = AppDatabase(openAppDatabase(dbFile));
      final adapter2 = DriftPackEditorAdapter(db2);

      final loaded = await adapter2.fetchPackDetail(created.pack.id);
      expect(loaded.pack.name, 'Persistent Pack');
      expect(loaded.pack.author, 'Persist Author');
      expect(loaded.emojiTags, ['Smile', 'Work']);
      expect(loaded.stickers.map((s) => s.id), ['stk-1', 'stk-2', 'stk-3']);

      await db2.close();
      await tempDir.delete(recursive: true);
    });

    test('packRepositoryProvider mengarah ke DriftPackEditorAdapter secara default', () {
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );
      addTearDown(container.dispose);

      final repository = container.read(packRepositoryProvider);
      expect(repository, isA<DriftPackEditorAdapter>());
    });
  });
}
