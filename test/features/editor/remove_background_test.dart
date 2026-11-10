import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/core/theme/app_theme.dart';
import 'package:sticker_studio/core/widgets/app_slider.dart';
import 'package:sticker_studio/features/editor/presentation/brush_mode_toggle.dart';
import 'package:sticker_studio/features/editor/presentation/loupe_magnifier.dart';
import 'package:sticker_studio/features/editor/presentation/remove_background_page.dart';

void main() {
  testWidgets(
    'RemoveBackgroundPage menampilkan mode toggle, slider, dan loupe',
    (tester) async {
      Map<String, dynamic>? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push<Map<String, dynamic>>(
                  MaterialPageRoute(
                    builder: (_) => const RemoveBackgroundPage(),
                  ),
                );
              },
              child: const Text('Buka RMBG'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka RMBG'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Background'), findsOneWidget);
      expect(find.byType(BrushModeToggle), findsOneWidget);
      expect(find.byType(LoupeMagnifier), findsOneWidget);
      expect(find.byType(AppSlider), findsNWidgets(2));

      // Ganti mode ke Restore
      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();

      // Tekan Terapkan
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!['mode'], 'Restore');
    },
  );
}
