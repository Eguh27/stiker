import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/core/theme/app_theme.dart';
import 'package:sticker_studio/core/widgets/app_slider.dart';
import 'package:sticker_studio/features/editor/presentation/border_editor_page.dart';
import 'package:sticker_studio/features/editor/presentation/border_preview_canvas.dart';
import 'package:sticker_studio/features/editor/presentation/color_palette_row.dart';

void main() {
  testWidgets(
    'BorderEditorPage menampilkan canvas, slider ketebalan, dan color palette',
    (tester) async {
      Map<String, dynamic>? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push<Map<String, dynamic>>(
                  MaterialPageRoute(builder: (_) => const BorderEditorPage()),
                );
              },
              child: const Text('Buka Border'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Border'));
      await tester.pumpAndSettle();

      expect(find.text('Border Stiker'), findsOneWidget);
      expect(find.byType(BorderPreviewCanvas), findsOneWidget);
      expect(find.byType(AppSlider), findsNWidgets(2));
      expect(find.byType(ColorPaletteRow), findsOneWidget);

      // Tekan Terapkan
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!['width'], 12.0);
    },
  );
}
