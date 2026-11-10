import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/core/theme/app_theme.dart';
import 'package:sticker_studio/features/data/project/project_providers.dart';
import 'package:sticker_studio/features/data/project/project_repository.dart';
import 'package:sticker_studio/features/editor/domain/scene_project.dart';
import 'package:sticker_studio/features/editor/domain/text_layer.dart';
import 'package:sticker_studio/features/editor/presentation/image_editor_page.dart';

class _InMemoryProjectRepo implements ProjectRepository {
  final Map<String, SceneProject> _storage = {};

  @override
  Future<SceneProject?> loadProject(String stickerId) async =>
      _storage[stickerId];

  @override
  Future<void> saveProject(String stickerId, SceneProject project) async {
    _storage[stickerId] = project;
  }

  @override
  Future<void> deleteProject(String stickerId) async {
    _storage.remove(stickerId);
  }

  @override
  Future<bool> hasProject(String stickerId) async =>
      _storage.containsKey(stickerId);
}

void main() {
  testWidgets(
    'Editor integration: buka, tambah teks, dan simpan ke repository',
    (tester) async {
      final repo = _InMemoryProjectRepo();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [projectRepositoryProvider.overrideWithValue(repo)],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const ImageEditorPage(stickerId: 'stk-integration'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit stiker'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);

      // Buka editor teks melalui toolbar
      await tester.tap(find.text('Teks'));
      await tester.pumpAndSettle();

      // Di TextEditorPage, masukkan teks baru
      expect(find.text('Editor Teks'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Stiker Keren');
      await tester.pumpAndSettle();

      // Simpan dari TextEditorPage
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      // Kembali ke ImageEditorPage, simpan ke repo
      expect(find.text('Edit stiker'), findsOneWidget);

      // Tekan Selesai di ImageEditorPage untuk menyimpan ke DB/Repo
      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();

      expect(repo._storage.containsKey('stk-integration'), isTrue);
      final saved = repo._storage['stk-integration']!;
      expect(
        saved.layers.any((l) => l is TextLayer && l.text == 'Stiker Keren'),
        isTrue,
      );
    },
  );
}
