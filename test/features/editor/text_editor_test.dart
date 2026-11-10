import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/core/widgets/top_bar.dart';
import 'package:sticker_studio/features/editor/domain/text_layer.dart';
import 'package:sticker_studio/features/editor/presentation/font_selector_row.dart';
import 'package:sticker_studio/features/editor/presentation/style_preset_row.dart';
import 'package:sticker_studio/features/editor/presentation/text_editor_page.dart';

void main() {
  testWidgets('TextEditorPage menampilkan input, font, preset, dan warna', (
    tester,
  ) async {
    TextLayer? returnedLayer;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              returnedLayer = await Navigator.of(context).push<TextLayer>(
                MaterialPageRoute(builder: (_) => const TextEditorPage()),
              );
            },
            child: const Text('Buka Editor'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buka Editor'));
    await tester.pumpAndSettle();

    expect(find.byType(TopBar), findsOneWidget);
    expect(find.text('Editor Teks'), findsOneWidget);
    expect(find.text('Terapkan'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(FontSelectorRow), findsOneWidget);
    expect(find.byType(StylePresetRow), findsOneWidget);

    // Ganti font ke Inter
    await tester.tap(find.text('Inter'));
    await tester.pumpAndSettle();

    // Ganti style ke Shadow
    await tester.tap(find.text('Shadow'));
    await tester.pumpAndSettle();

    // Tulis teks baru
    await tester.enterText(find.byType(TextField), 'STIKER KEREN');
    await tester.pumpAndSettle();

    // Tekan Terapkan
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    expect(returnedLayer, isNotNull);
    expect(returnedLayer!.text, 'STIKER KEREN');
    expect(returnedLayer!.fontFamily, 'Inter');
    expect(returnedLayer!.presetStyle, 'Shadow');
  });
}
