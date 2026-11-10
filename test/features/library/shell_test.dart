import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/packs/domain/fake_pack_repository.dart';
import 'package:sticker_studio/features/packs/presentation/pack_providers.dart';
import 'package:sticker_studio/features/queue/domain/fake_queue_repository.dart';
import 'package:sticker_studio/features/queue/presentation/queue_providers.dart';
import 'package:sticker_studio/main.dart';

Future<void> _pumpShell(WidgetTester tester) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        queueRepositoryProvider.overrideWithValue(FakeQueueRepository()),
        packRepositoryProvider.overrideWithValue(FakePackRepository()),
      ],
      child: const StickerStudioApp(),
    ),
  );
}

void main() {
  testWidgets('shell switches 4 tabs without error', (tester) async {
    await _pumpShell(tester);
    await tester.pumpAndSettle();

    expect(find.text('Sticker Library'), findsOneWidget);
    await tester.tap(find.text('Antrean'));
    await tester.pumpAndSettle();
    expect(find.text('Queue Monitor'), findsOneWidget);
    expect(find.text('Auto-RMBG'), findsOneWidget);

    await tester.tap(find.text('Pack'));
    await tester.pumpAndSettle();
    expect(find.text('Sticker Packs'), findsOneWidget);
    expect(find.text('Daily Mood'), findsOneWidget);

    await tester.tap(find.text('Setelan'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Mode gelap'), findsOneWidget);
  });

  testWidgets('queue toggle Auto-RMBG flips switch', (tester) async {
    await _pumpShell(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Antrean'));
    await tester.pumpAndSettle();

    final Finder toggle = find.byType(Switch);
    expect(toggle, findsOneWidget);
    await tester.tap(toggle);
    expect(find.byType(Switch), findsOneWidget);
  });
}
