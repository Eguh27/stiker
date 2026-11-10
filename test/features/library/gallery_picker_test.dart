import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/core/theme/app_theme.dart';
import 'package:sticker_studio/core/widgets/state_panels.dart';
import 'package:sticker_studio/features/library/domain/fake_sticker_repository.dart';
import 'package:sticker_studio/features/library/domain/sticker_repository.dart';
import 'package:sticker_studio/features/library/presentation/gallery_picker_page.dart';
import 'package:sticker_studio/features/library/presentation/photo_grid.dart';
import 'package:sticker_studio/features/library/presentation/photo_tile.dart';
import 'package:sticker_studio/features/library/presentation/sticker_grid.dart';
import 'package:sticker_studio/features/library/presentation/sticker_providers.dart';

Future<void> _pump(WidgetTester tester, StickerRepository repository) {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    ProviderScope(
      overrides: [stickerRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const GalleryPickerPage(),
      ),
    ),
  );
}

void main() {
  testWidgets('loading then 12 photos, 3 selected by default', (tester) async {
    await _pump(tester, FakeStickerRepository());
    await tester.pump();
    expect(find.byType(LoadingState, skipOffstage: false), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(PhotoTile, skipOffstage: false), findsNWidgets(12));
    expect(find.text('3 terpilih'), findsOneWidget);
  });

  testWidgets('toggle tile updates count, import disabled when zero', (
    tester,
  ) async {
    await _pump(tester, FakeStickerRepository());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PhotoTile, skipOffstage: false).at(0));
    await tester.pumpAndSettle();
    expect(find.text('2 terpilih'), findsOneWidget);
    await tester.tap(find.text('Pilih semua'));
    await tester.pumpAndSettle();
    expect(find.text('12 terpilih'), findsOneWidget);
    expect(find.text('Hapus semua'), findsOneWidget);
    await tester.tap(find.text('Hapus semua'));
    await tester.pumpAndSettle();
    expect(find.text('0 terpilih'), findsOneWidget);
    final FilledButton importButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Import'),
    );
    expect(importButton.onPressed, isNull);
  });

  testWidgets('empty and error states', (tester) async {
    await _pump(tester, FakeStickerRepository.empty());
    await tester.pumpAndSettle();
    expect(find.byType(EmptyState, skipOffstage: false), findsOneWidget);

    await _pump(tester, FakeStickerRepository.failing());
    await tester.pumpAndSettle();
    expect(find.byType(ErrorState, skipOffstage: false), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  test('sticker grid columns responsive', () {
    expect(stickerColumnsFor(375), 2);
    expect(stickerColumnsFor(700), 3);
    expect(stickerColumnsFor(1200), 4);
    expect(galleryColumnsFor(375), 3);
    expect(galleryColumnsFor(700), 4);
    expect(galleryColumnsFor(1200), 6);
  });

  testWidgets('responsive library grid at wide viewport', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stickerRepositoryProvider.overrideWithValue(FakeStickerRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const Scaffold(
            body: SizedBox(width: 1100, child: StickerGrid(stickers: [])),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final GridView grid = tester.widget<GridView>(find.byType(GridView));
    final SliverGridDelegateWithFixedCrossAxisCount delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 4);
  });
}
