import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/core/widgets/top_bar.dart';
import 'package:sticker_studio/features/data/project/project_providers.dart';
import 'package:sticker_studio/features/data/project/project_repository.dart';
import 'package:sticker_studio/features/editor/domain/scene_project.dart';
import 'package:sticker_studio/features/editor/presentation/editor_action_bar.dart';
import 'package:sticker_studio/features/editor/presentation/editor_canvas.dart';
import 'package:sticker_studio/features/editor/presentation/editor_layer_panel.dart';
import 'package:sticker_studio/features/editor/presentation/editor_toolbar.dart';
import 'package:sticker_studio/features/editor/presentation/image_editor_page.dart';

class _FakeProjectRepo implements ProjectRepository {
  SceneProject? savedProject;

  @override
  Future<void> saveProject(String stickerId, SceneProject project) async {
    savedProject = project;
  }

  @override
  Future<SceneProject?> loadProject(String stickerId) async => savedProject;

  @override
  Future<void> deleteProject(String stickerId) async => savedProject = null;

  @override
  Future<bool> hasProject(String stickerId) async => savedProject != null;
}

void main() {
  testWidgets(
    'ImageEditorPage menampilkan komponen lengkap dan manipulasi layer',
    (tester) async {
      final fakeRepo = _FakeProjectRepo();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [projectRepositoryProvider.overrideWithValue(fakeRepo)],
          child: const MaterialApp(
            home: ImageEditorPage(stickerId: 'test-stk'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TopBar), findsOneWidget);
      expect(find.text('Edit stiker'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
      expect(find.byType(EditorActionBar), findsOneWidget);
      expect(find.byType(EditorCanvas), findsOneWidget);
      expect(find.byType(EditorToolbar), findsOneWidget);

      // Buka panel layer
      await tester.tap(find.byTooltip('Layer'));
      await tester.pumpAndSettle();
      expect(find.byType(EditorLayerPanel), findsOneWidget);
      expect(find.text('Stiker utama'), findsOneWidget);

      // Tutup panel layer
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(EditorLayerPanel), findsNothing);

      // Tekan tool Stiker di toolbar untuk tambah layer
      await tester.tap(find.text('Stiker'));
      await tester.pumpAndSettle();

      // Undo aktif
      expect(find.byTooltip('Undo'), findsOneWidget);
      await tester.tap(find.byTooltip('Undo'));
      await tester.pumpAndSettle();

      // Redo aktif
      expect(find.byTooltip('Redo'), findsOneWidget);
      await tester.tap(find.byTooltip('Redo'));
      await tester.pumpAndSettle();

      // Tekan Selesai
      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();
      expect(fakeRepo.savedProject, isNotNull);
    },
  );
}
