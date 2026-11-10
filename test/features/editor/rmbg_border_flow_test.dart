import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/core/theme/app_theme.dart';
import 'package:sticker_studio/features/data/project/project_providers.dart';
import 'package:sticker_studio/features/data/project/project_repository.dart';
import 'package:sticker_studio/features/editor/domain/scene_project.dart';
import 'package:sticker_studio/features/editor/presentation/image_editor_page.dart';

class _NoopRepo implements ProjectRepository {
  @override
  Future<void> deleteProject(String stickerId) async {}

  @override
  Future<bool> hasProject(String stickerId) async => false;

  @override
  Future<SceneProject?> loadProject(String stickerId) async => null;

  @override
  Future<void> saveProject(String stickerId, SceneProject project) async {}
}

void main() {
  testWidgets('ImageEditor toolbar Hapus BG dan Border flow', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [projectRepositoryProvider.overrideWithValue(_NoopRepo())],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const ImageEditorPage(stickerId: 'stk-flow'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Buka Hapus BG
    await tester.tap(find.text('Hapus BG'));
    await tester.pumpAndSettle();

    expect(find.text('Hapus Background'), findsOneWidget);
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    // Dismiss SnackBar agar tidak menghalangi toolbar bawah
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Edit stiker'), findsOneWidget);

    // Buka Border
    await tester.tap(find.text('Border'));
    await tester.pumpAndSettle();

    expect(find.text('Border Stiker'), findsOneWidget);
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    expect(find.text('Edit stiker'), findsOneWidget);
  });
}
