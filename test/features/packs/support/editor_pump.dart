import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/library/domain/sticker.dart';
import 'package:sticker_studio/features/packs/domain/pack_repository.dart';
import 'package:sticker_studio/features/packs/presentation/pack_editor_page.dart';
import 'package:sticker_studio/features/packs/presentation/pack_providers.dart';

/// Viewport tinggi: form editor lebih panjang dari layar 800×600 dan
/// `ListView` tidak men-build widget di luar viewport (lazy), sehingga test
/// memakai layar tinggi agar seluruh isi form ter-build sekaligus.
void pumpTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Scaffold editor dengan sudut pandang tinggi.
Future<void> pumpEditor(
  WidgetTester tester, {
  String? packId,
  required PackEditorRepository repository,
}) async {
  int mockCount = 0;
  pumpTallViewport(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        packRepositoryProvider.overrideWithValue(repository),
        stickerPickerLauncherProvider.overrideWithValue(({
          required context,
          required alreadySelectedIds,
          required maxSelectable,
        }) async {
          mockCount++;
          return [
            Sticker(
              id: 'mock-s-$mockCount',
              label: 'Mock $mockCount',
              colorKind: StickerColorKind.lavender,
              shape: StickerShape.blob,
            ),
          ];
        }),
      ],
      child: MaterialApp(home: PackEditorPage(packId: packId)),
    ),
  );
}

ProviderContainer editorContainerOf(WidgetTester tester) {
  return ProviderScope.containerOf(
    tester.element(find.text('Editor Pack').first),
  );
}

/// Isi TextField lalu lepas fokus: caret yang masih berkedip membuat
/// `pumpAndSettle` tidak pernah selesai.
Future<void> fillAndUnfocus(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.enterText(finder, text);
  await tester.pump();
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
}

/// PumpAndSettle terbatas: timeout bawaan 10 menit membuat kegagalan
/// terasa seperti gagal; 5 detik fake-time cukup untuk animasi + delay mock
/// (2×100 ms) tanpa menggantung proses test.
Future<void> pumpSettled(WidgetTester tester) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.paint,
    const Duration(seconds: 5),
  );
}
