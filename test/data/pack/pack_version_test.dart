import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/pack/pack_details.dart';
import 'package:sticker_studio/features/data/pack/pack_validation.dart';

import 'support/pack_workspace.dart';

void main() {
  late PackWorkspace workspace;

  setUp(() async => workspace = await PackWorkspace.create());
  tearDown(() => workspace.dispose());

  Future<PackDetails> create({List<String>? stickerIds}) {
    return workspace.repository.createPack(
      name: 'Pack',
      author: 'Author',
      trayIconPath: '/tray.webp',
      stickerIds: stickerIds ?? workspace.stickerIds(4),
    );
  }

  test('update tanpa perubahan konten tidak menaikkan versi', () async {
    final PackDetails pack = await create();

    final PackDetails updated = await workspace.repository.updatePack(
      id: pack.id,
      name: pack.name,
      author: pack.author,
      trayIconPath: pack.trayIconPath,
      stickerIds: pack.stickerIds,
    );

    expect(updated.version, '1');
  });

  test('update menaikkan versi tepat sekali per perubahan konten', () async {
    final PackDetails pack = await create();

    final PackDetails renamed = await workspace.repository.updatePack(
      id: pack.id,
      name: 'Pack Baru',
      author: pack.author,
      trayIconPath: pack.trayIconPath,
      stickerIds: pack.stickerIds,
    );
    expect(renamed.version, '2');
    expect(renamed.name, 'Pack Baru');

    final PackDetails repeated = await workspace.repository.updatePack(
      id: pack.id,
      name: 'Pack Baru',
      author: pack.author,
      trayIconPath: pack.trayIconPath,
      stickerIds: pack.stickerIds,
    );
    expect(repeated.version, '2');

    final PackDetails reduced = await workspace.repository.updatePack(
      id: pack.id,
      name: 'Pack Baru',
      author: pack.author,
      trayIconPath: pack.trayIconPath,
      stickerIds: workspace.stickerIds(3),
    );
    expect(reduced.version, '3');
    expect(reduced.stickerCount, 3);

    final PackDetails combined = await workspace.repository.updatePack(
      id: pack.id,
      name: 'Pack Gabungan',
      author: pack.author,
      trayIconPath: pack.trayIconPath,
      stickerIds: workspace.stickerIds(4),
    );
    expect(combined.version, '4');
    expect(combined.stickerCount, 4);
  });

  test('update isSynced lewat updatePack menaikkan versi', () async {
    final PackDetails pack = await create();

    final PackDetails synced = await workspace.repository.updatePack(
      id: pack.id,
      name: pack.name,
      author: pack.author,
      trayIconPath: pack.trayIconPath,
      stickerIds: pack.stickerIds,
      isSynced: true,
    );

    expect(synced.isSynced, isTrue);
    expect(synced.version, '2');
  });

  test('reorder mengubah posisi dan versi sekali', () async {
    final PackDetails pack = await create();
    final List<String> reversed = pack.stickerIds.reversed.toList();

    final PackDetails reordered = await workspace.repository.reorderStickers(
      packId: pack.id,
      stickerIds: reversed,
    );
    expect(reordered.version, '2');
    expect(reordered.stickerIds, reversed);

    final List<PackSticker> rows = await (workspace.database.select(
      workspace.database.packStickers,
    )..orderBy([(row) => OrderingTerm.asc(row.position)])).get();
    expect(rows.map((row) => row.stickerId), reversed);
    expect(rows.map((row) => row.position), [0, 1, 2, 3]);

    final PackDetails repeated = await workspace.repository.reorderStickers(
      packId: pack.id,
      stickerIds: reversed,
    );
    expect(repeated.version, '2');
  });

  test('update yang hanya mengubah urutan menaikkan versi sekali', () async {
    final PackDetails pack = await create();
    final List<String> reversed = pack.stickerIds.reversed.toList();

    final PackDetails updated = await workspace.repository.updatePack(
      id: pack.id,
      name: pack.name,
      author: pack.author,
      trayIconPath: pack.trayIconPath,
      stickerIds: reversed,
    );

    expect(updated.version, '2');
    expect(updated.stickerIds, reversed);
  });

  test('reorder menolak daftar stiker yang berbeda', () async {
    final PackDetails pack = await create();

    await expectLater(
      workspace.repository.reorderStickers(
        packId: pack.id,
        stickerIds: ['sticker-1', 'sticker-2', 'sticker-5'],
      ),
      throwsA(isA<PackValidationException>()),
    );
    expect((await workspace.repository.fetchPack(pack.id)).version, '1');
  });

  test('setSynced idempoten dan menaikkan versi sekali', () async {
    final PackDetails pack = await create();

    final PackDetails synced = await workspace.repository.setSynced(
      pack.id,
      true,
    );
    expect(synced.version, '2');

    final PackDetails repeated = await workspace.repository.setSynced(
      pack.id,
      true,
    );
    expect(repeated.version, '2');

    final PackDetails unsynced = await workspace.repository.setSynced(
      pack.id,
      false,
    );
    expect(unsynced.version, '3');
  });

  test('update tidak valid tidak mengubah data lama', () async {
    final PackDetails pack = await create();

    await expectLater(
      workspace.repository.updatePack(
        id: pack.id,
        name: 'x' * 29,
        author: pack.author,
        trayIconPath: pack.trayIconPath,
        stickerIds: pack.stickerIds,
      ),
      throwsA(isA<PackValidationException>()),
    );

    final PackDetails stored = await workspace.repository.fetchPack(pack.id);
    expect(stored.name, 'Pack');
    expect(stored.version, '1');
  });

  test(
    'perubahan emoji menaikkan versi dan emoji identik tidak menaikkan',
    () async {
      final PackDetails pack = await create();

      final PackDetails withEmoji = await workspace.repository.updatePack(
        id: pack.id,
        name: pack.name,
        author: pack.author,
        trayIconPath: pack.trayIconPath,
        stickerIds: pack.stickerIds,
        emojis: ['Smile'],
      );
      expect(withEmoji.version, '2');
      expect(withEmoji.emojis, ['Smile']);

      final PackDetails repeatedEmoji = await workspace.repository.updatePack(
        id: pack.id,
        name: pack.name,
        author: pack.author,
        trayIconPath: pack.trayIconPath,
        stickerIds: pack.stickerIds,
        emojis: ['Smile'],
      );
      expect(repeatedEmoji.version, '2');

      final PackDetails changedEmoji = await workspace.repository.updatePack(
        id: pack.id,
        name: pack.name,
        author: pack.author,
        trayIconPath: pack.trayIconPath,
        stickerIds: pack.stickerIds,
        emojis: ['Smile', 'Party'],
      );
      expect(changedEmoji.version, '3');
      expect(changedEmoji.emojis, ['Smile', 'Party']);
    },
  );
}
