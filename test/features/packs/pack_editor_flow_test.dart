import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/library/domain/sticker.dart';
import 'package:sticker_studio/features/packs/domain/fake_pack_repository.dart';
import 'package:sticker_studio/features/packs/domain/pack_editor_state.dart';
import 'package:sticker_studio/features/packs/domain/pack_repository.dart';
import 'package:sticker_studio/features/packs/domain/sticker_pack.dart';
import 'package:sticker_studio/features/packs/presentation/pack_editor_page.dart';
import 'package:sticker_studio/features/packs/presentation/pack_editor_providers.dart';
import 'package:sticker_studio/features/packs/presentation/pack_providers.dart';
import 'package:sticker_studio/features/packs/presentation/packs_page.dart';

import 'support/editor_pump.dart';

/// Reorder sel 1 → sel 2 lewat long-press drag (helper grid).
Future<void> dragCellOneToTwo(WidgetTester tester) async {
  final Offset from = tester.getCenter(
    find.byKey(const ValueKey<String>('pack-cell-1')),
  );
  final Offset to = tester.getCenter(
    find.byKey(const ValueKey<String>('pack-cell-2')),
  );
  final TestGesture gesture = await tester.startGesture(from);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  const int steps = 6;
  final Offset delta = (to - from) / steps.toDouble();
  for (int step = 0; step < steps; step++) {
    await gesture.moveBy(delta);
    await tester.pump(const Duration(milliseconds: 40));
  }
  await tester.pump(const Duration(milliseconds: 100));
  await gesture.up();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

class _SaveFailFake extends FakePackRepository {
  @override
  Future<PackDetail> createPack({
    required String name,
    required String author,
    List<Sticker> stickers = const [],
    List<String> emojiTags = const [],
  }) async {
    throw StateError('offline');
  }
}

void main() {
  testWidgets('drag&drop menukar urutan stiker', (tester) async {
    final FakePackRepository fake = FakePackRepository();
    await pumpEditor(tester, packId: 'p1', repository: fake);
    await tester.pumpAndSettle();

    await dragCellOneToTwo(tester);

    final PackEditorState state = editorContainerOf(tester)
        .read(packEditorProvider('p1'));
    expect(state.stickers.first.id, 'p1-s2');
    expect(state.stickers[1].id, 'p1-s1');
  });

  testWidgets('Simpan pack baru masuk repository & balik ke list', (
    tester,
  ) async {
    final FakePackRepository fake = FakePackRepository();
    int mockCount = 0;
    pumpTallViewport(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packRepositoryProvider.overrideWithValue(fake),
          stickerPickerLauncherProvider.overrideWithValue(({
            required context,
            required alreadySelectedIds,
            required maxSelectable,
          }) async {
            mockCount++;
            return [
              Sticker(
                id: 'mock-flow-$mockCount',
                label: 'Mock Flow $mockCount',
                colorKind: StickerColorKind.lavender,
                shape: StickerShape.blob,
              ),
            ];
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: PacksPage())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Tambah pack'));
    await tester.pumpAndSettle();
    await fillAndUnfocus(tester, find.byType(TextField).first, 'Pack Coba');

    await tester.tap(find.text('Tambah stiker'));
    await tester.pump();
    for (int step = 0; step < 2; step++) {
      await tester.tap(find.text('Tambah'));
      await tester.pump();
    }

    await tester.tap(find.text('Simpan'));
    await pumpSettled(tester);

    expect(find.text('Sticker Packs'), findsOneWidget);
    expect(find.text('Pack Coba'), findsOneWidget);
    expect(fake.packs, hasLength(4));
    expect(fake.packs.last.name, 'Pack Coba');
    expect(fake.packs.last.stickerCount, 3);
  });

  testWidgets('Simpan pack sunting memakai update + reorder', (tester) async {
    final FakePackRepository fake = FakePackRepository();
    await pumpEditor(tester, packId: 'p1', repository: fake);
    await tester.pumpAndSettle();

    await fillAndUnfocus(tester, find.byType(TextField).first, 'Daily Editor');
    await dragCellOneToTwo(tester);

    await tester.tap(find.text('Simpan'));
    await pumpSettled(tester);

    expect(
      fake.packs.firstWhere((StickerPack p) => p.id == 'p1').name,
      'Daily Editor',
    );
    final List<Sticker> stickers = fake.stickersOf('p1');
    expect(stickers.first.id, 'p1-s2');
    expect(stickers[1].id, 'p1-s1');
  });

  testWidgets('Simpan gagal memunculkan SnackBar tanpa keluar', (tester) async {
    await pumpEditor(tester, repository: _SaveFailFake());
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Simpan'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Gagal menyimpan pack'), findsOneWidget);
    expect(find.text('Editor Pack'), findsOneWidget);

    await pumpSettled(tester);
  });

  testWidgets('hapus stiker dari pack hanya mengubah draft', (tester) async {
    final FakePackRepository fake = FakePackRepository();
    await pumpEditor(tester, packId: 'p1', repository: fake);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('pack-remove-p1-s1')));
    await tester.pumpAndSettle();

    final PackEditorState state = editorContainerOf(tester)
        .read(packEditorProvider('p1'));
    expect(state.stickers, hasLength(17));
    expect(state.stickers.map((Sticker s) => s.id), isNot(contains('p1-s1')));
    expect(
      fake.packs.firstWhere((StickerPack p) => p.id == 'p1').stickerCount,
      18,
    );
  });

  testWidgets('hapus pack dari kartu meminta konfirmasi', (tester) async {
    final FakePackRepository fake = FakePackRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [packRepositoryProvider.overrideWithValue(fake)],
        child: const MaterialApp(home: PacksPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('pack-delete-p1')));
    await tester.pumpAndSettle();
    expect(find.text('Hapus pack?'), findsOneWidget);
    expect(
      find.textContaining('Stiker aslinya tetap ada di Library'),
      findsOneWidget,
    );

    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(fake.packs.map((StickerPack p) => p.id), isNot(contains('p1')));
    expect(find.text('Daily Mood'), findsNothing);
  });
}
