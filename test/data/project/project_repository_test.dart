import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/project/project_repository_impl.dart';
import 'package:sticker_studio/features/editor/domain/scene_layer.dart';
import 'package:sticker_studio/features/editor/domain/scene_project.dart';
import 'package:sticker_studio/features/editor/domain/text_layer.dart';

import '../support/database_fixtures.dart';
import '../support/test_database.dart';

void main() {
  group('ProjectRepositoryImpl', () {
    late AppDatabase database;
    late ProjectRepositoryImpl repository;

    setUp(() async {
      database = createTestDatabase();
      repository = ProjectRepositoryImpl(database);
      await insertSticker(database, id: 'stk-test-1');
    });

    tearDown(() => database.close());

    test(
      'saveProject menyimpan project dan loadProject membaca kembali',
      () async {
        const project = SceneProject(
          layers: [
            ImageLayer(id: 'l1', imagePath: '/path/1.webp'),
            TextLayer(id: 'l2', text: 'Sticker Studio'),
          ],
        );

        await repository.saveProject('stk-test-1', project);
        expect(await repository.hasProject('stk-test-1'), isTrue);

        final loaded = await repository.loadProject('stk-test-1');
        expect(loaded, isNotNull);
        expect(loaded!.layers, hasLength(2));
        expect((loaded.layers.last as TextLayer).text, 'Sticker Studio');
      },
    );

    test('saveProject memperbarui project yang sudah ada (update)', () async {
      const p1 = SceneProject(
        layers: [ImageLayer(id: 'l1', imagePath: '/path/1.webp')],
      );
      await repository.saveProject('stk-test-1', p1);

      const p2 = SceneProject(
        layers: [
          ImageLayer(id: 'l1', imagePath: '/path/1.webp'),
          TextLayer(id: 'l2', text: 'Updated!'),
        ],
      );
      await repository.saveProject('stk-test-1', p2);

      final loaded = await repository.loadProject('stk-test-1');
      expect(loaded!.layers, hasLength(2));
      expect((loaded.layers.last as TextLayer).text, 'Updated!');
    });

    test('deleteProject menghapus project dari database', () async {
      const project = SceneProject(
        layers: [ImageLayer(id: 'l1', imagePath: '/path/1.webp')],
      );
      await repository.saveProject('stk-test-1', project);
      expect(await repository.hasProject('stk-test-1'), isTrue);

      await repository.deleteProject('stk-test-1');
      expect(await repository.hasProject('stk-test-1'), isFalse);
      expect(await repository.loadProject('stk-test-1'), isNull);
    });
  });
}
