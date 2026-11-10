import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/core/theme/app_theme.dart';
import 'package:sticker_studio/core/widgets/state_panels.dart';
import 'package:sticker_studio/features/library/domain/fake_sticker_repository.dart';
import 'package:sticker_studio/features/library/domain/sticker_repository.dart';
import 'package:sticker_studio/features/library/presentation/library_page.dart';
import 'package:sticker_studio/features/library/presentation/sticker_card.dart';
import 'package:sticker_studio/features/library/presentation/sticker_providers.dart';

Future<void> _pump(WidgetTester tester, StickerRepository repository) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [stickerRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const LibraryPage(),
      ),
    ),
  );
}

void main() {
  testWidgets('shows loading then 8 stickers', (tester) async {
    await _pump(tester, FakeStickerRepository());
    expect(find.byType(LoadingState), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(StickerCard), findsNWidgets(8));
    expect(find.text('OK!'), findsOneWidget);
    expect(find.text('YES'), findsNWidgets(2));
  });

  testWidgets('shows empty state for empty repository', (tester) async {
    await _pump(tester, FakeStickerRepository.empty());
    await tester.pumpAndSettle();
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('Belum ada stiker'), findsOneWidget);
  });

  testWidgets('shows error state with retry', (tester) async {
    await _pump(tester, FakeStickerRepository.failing());
    await tester.pumpAndSettle();
    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('FAB opens import sheet', (tester) async {
    await _pump(tester, FakeStickerRepository());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tambah stiker'));
    await tester.pumpAndSettle();
    expect(find.text('Impor stiker'), findsOneWidget);
    expect(find.text('Dari galeri'), findsOneWidget);
    expect(find.text('Bulk import'), findsOneWidget);
  });

  testWidgets('segmented filters to 4 stickers', (tester) async {
    await _pump(tester, FakeStickerRepository());
    await tester.pumpAndSettle();
    expect(find.byType(StickerCard), findsNWidgets(8));
    await tester.tap(find.text('Inbox / Baru 8'));
    await tester.pump();
    expect(find.byType(StickerCard), findsNWidgets(4));
  });
}
