import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/core/theme/app_theme.dart';
import 'package:sticker_studio/core/widgets/state_panels.dart';
import 'package:sticker_studio/features/queue/domain/fake_queue_repository.dart';
import 'package:sticker_studio/features/queue/domain/queue_repository.dart';
import 'package:sticker_studio/features/queue/presentation/queue_page.dart';
import 'package:sticker_studio/features/queue/presentation/queue_providers.dart';

Future<void> _pump(WidgetTester tester, QueueRepository repository) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [queueRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const QueuePage(),
      ),
    ),
  );
}

void main() {
  testWidgets('fake: progres + sumber + retry via domain', (tester) async {
    await _pump(tester, FakeQueueRepository());
    await tester.pump();
    expect(find.byType(LoadingState, skipOffstage: false), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('68%'), findsOneWidget);
    expect(find.text('Pinterest'), findsOneWidget);
    expect(find.text('Link'), findsOneWidget);
    expect(find.text('Galeri'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsWidgets);
  });

  testWidgets('fake: retry mengubah Gagal ke Pending', (tester) async {
    final FakeQueueRepository repository = FakeQueueRepository();
    await _pump(tester, repository);
    await tester.pumpAndSettle();
    expect(find.text('Gagal'), findsWidgets);
    await tester.tap(find.text('Retry').first);
    await tester.pumpAndSettle();
    expect(find.text('Pending'), findsWidgets);
  });

  testWidgets('tabs Dalam proses vs Baru Diimpor', (tester) async {
    await _pump(tester, FakeQueueRepository());
    await tester.pumpAndSettle();
    expect(find.text('Dalam proses 3'), findsOneWidget);
    expect(find.text('Baru Diimpor 1'), findsOneWidget);
    await tester.tap(find.text('Baru Diimpor 1'));
    await tester.pumpAndSettle();
    expect(find.text('Selesai'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('empty dan error state nyata', (tester) async {
    await _pump(tester, FakeQueueRepository.empty());
    await tester.pumpAndSettle();
    expect(find.byType(EmptyState, skipOffstage: false), findsOneWidget);

    await _pump(tester, FakeQueueRepository.failing());
    await tester.pumpAndSettle();
    expect(find.byType(ErrorState, skipOffstage: false), findsOneWidget);
  });

  testWidgets('toggle Auto-RMBG persist via provider', (tester) async {
    final FakeQueueRepository repository = FakeQueueRepository();
    await _pump(tester, repository);
    await tester.pumpAndSettle();
    final Finder toggle = find.byType(Switch);
    expect(toggle, findsOneWidget);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(repository.autoRmbg, isFalse);
  });
}
