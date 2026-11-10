import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/pack/pack_details.dart';
import 'package:sticker_studio/features/data/pack/pack_validation.dart';
import 'package:sticker_studio/features/packs/domain/sticker_pack.dart';

import 'support/pack_workspace.dart';

Matcher throwsPackMessage(String fragment) {
  return throwsA(
    isA<PackValidationException>().having(
      (PackValidationException error) => error.message,
      'message',
      contains(fragment),
    ),
  );
}

void main() {
  late PackWorkspace workspace;

  setUp(() async => workspace = await PackWorkspace.create());
  tearDown(() => workspace.dispose());

  test('create menyimpan pack, posisi 0..n-1, versi 1', () async {
    final PackDetails pack = await workspace.repository.createPack(
      name: '  Daily Mood  ',
      author: '  Ana  ',
      trayIconPath: '  /tray.webp  ',
      stickerIds: workspace.stickerIds(3),
    );

    expect(pack.name, 'Daily Mood');
    expect(pack.author, 'Ana');
    expect(pack.trayIconPath, '/tray.webp');
    expect(pack.version, '1');
    expect(pack.isSynced, isFalse);
    expect(pack.stickerIds, workspace.stickerIds(3));

    final PackDetails fetched = await workspace.repository.fetchPack(pack.id);
    expect(fetched.stickerIds, workspace.stickerIds(3));
    final List<StickerPack> packs = await workspace.repository.fetchPacks();
    expect(packs.single.stickerCount, 3);

    final rows = await (workspace.database.select(
      workspace.database.packStickers,
    )..orderBy([(row) => OrderingTerm.asc(row.position)])).get();
    expect(rows.map((row) => row.position), [0, 1, 2]);
  });

  test('create menerima batas maksimum 30 stiker', () async {
    final PackDetails pack = await workspace.repository.createPack(
      name: 'Penuh',
      author: 'Author',
      trayIconPath: '/tray.webp',
      stickerIds: workspace.stickerIds(30),
    );

    expect(pack.stickerCount, 30);
    expect((await workspace.repository.fetchPacks()).single.stickerCount, 30);
  });

  test('create menerima nama dan pembuat tepat 28 karakter', () async {
    final PackDetails pack = await workspace.repository.createPack(
      name: 'n' * 28,
      author: 'a' * 28,
      trayIconPath: '/tray.webp',
      stickerIds: workspace.stickerIds(3),
    );

    expect(pack.name, 'n' * 28);
    expect(pack.author, 'a' * 28);
  });

  test('create menolak jumlah, teks, duplikat, dan stiker hilang', () async {
    Future<PackDetails> create({
      String name = 'Pack',
      String author = 'Author',
      String trayIconPath = '/tray.webp',
      List<String>? stickerIds,
    }) {
      return workspace.repository.createPack(
        name: name,
        author: author,
        trayIconPath: trayIconPath,
        stickerIds: stickerIds ?? workspace.stickerIds(3),
      );
    }

    await expectLater(
      create(stickerIds: workspace.stickerIds(2)),
      throwsPackMessage('minimal 3'),
    );
    await expectLater(
      create(stickerIds: workspace.stickerIds(31)),
      throwsPackMessage('maksimal 30'),
    );
    await expectLater(create(name: '   '), throwsPackMessage('Nama wajib'));
    await expectLater(
      create(author: '   '),
      throwsPackMessage('Pembuat wajib'),
    );
    await expectLater(
      create(trayIconPath: '   '),
      throwsPackMessage('Tray icon wajib'),
    );
    await expectLater(
      create(name: 'x' * 29),
      throwsPackMessage('Nama maksimal 28'),
    );
    await expectLater(
      create(author: 'x' * 29),
      throwsPackMessage('Pembuat maksimal 28'),
    );
    await expectLater(
      create(stickerIds: ['sticker-1', 'sticker-1', 'sticker-2']),
      throwsPackMessage('duplikat'),
    );
    await expectLater(
      create(stickerIds: ['sticker-1', 'sticker-2', 'missing']),
      throwsPackMessage('tidak ditemukan'),
    );
  });

  test('delete menghapus pack dan baris pack_stickers', () async {
    final PackDetails pack = await workspace.repository.createPack(
      name: 'Hapus',
      author: 'Author',
      trayIconPath: '/tray.webp',
      stickerIds: workspace.stickerIds(3),
    );

    await workspace.repository.deletePack(pack.id);

    await expectLater(
      workspace.repository.fetchPack(pack.id),
      throwsPackMessage('tidak ditemukan'),
    );
    final rows = await (workspace.database.select(
      workspace.database.packStickers,
    )..where((row) => row.packId.equals(pack.id))).get();
    expect(rows, isEmpty);
  });

  test('fetchPack yang tidak ada memberi pesan jelas', () async {
    await expectLater(
      workspace.repository.fetchPack('missing-pack'),
      throwsPackMessage('missing-pack'),
    );
  });

  test(
    'create dan fetchPack menyimpan dan membaca ulang emoji (0..3)',
    () async {
      final PackDetails emptyEmoji = await workspace.repository.createPack(
        name: 'No Emoji',
        author: 'Author',
        trayIconPath: '/tray.webp',
        stickerIds: workspace.stickerIds(3),
        emojis: const [],
      );
      expect(emptyEmoji.emojis, isEmpty);

      final PackDetails withEmoji = await workspace.repository.createPack(
        name: 'With Emoji',
        author: 'Author',
        trayIconPath: '/tray.webp',
        stickerIds: workspace.stickerIds(3),
        emojis: ['Smile', 'Love', 'Party'],
      );
      expect(withEmoji.emojis, ['Smile', 'Love', 'Party']);

      final PackDetails fetched = await workspace.repository.fetchPack(
        withEmoji.id,
      );
      expect(fetched.emojis, ['Smile', 'Love', 'Party']);
    },
  );

  test('validasi emoji menolak >3, duplikat, dan opsi tidak valid', () async {
    Future<PackDetails> createWithEmoji(List<String> emojis) {
      return workspace.repository.createPack(
        name: 'Emoji Test',
        author: 'Author',
        trayIconPath: '/tray.webp',
        stickerIds: workspace.stickerIds(3),
        emojis: emojis,
      );
    }

    await expectLater(
      createWithEmoji(['Smile', 'Love', 'Party', 'Work']),
      throwsPackMessage('maksimal 3'),
    );
    await expectLater(
      createWithEmoji(['Smile', 'Smile']),
      throwsPackMessage('duplikat'),
    );
    await expectLater(
      createWithEmoji(['Angry']),
      throwsPackMessage('tidak valid'),
    );
  });
}
