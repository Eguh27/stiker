import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/project/project_scene_renderer.dart';
import 'package:sticker_studio/features/editor/domain/scene_layer.dart';
import 'package:sticker_studio/features/editor/domain/scene_project.dart';
import 'package:sticker_studio/features/editor/domain/text_layer.dart';

void main() {
  test('ProjectSceneRenderer merender layers dan memanggil encoder', () async {
    final tempDir = await Directory.systemTemp.createTemp('render_test_');
    final outPath = '${tempDir.path}/out.webp';

    var encodedCalled = false;
    final renderer = ProjectSceneRenderer(
      encodeWebp: (input, output, targetKb) async {
        encodedCalled = true;
        expect(File(input).existsSync(), isTrue);
        expect(output, outPath);
        return output;
      },
    );

    const project = SceneProject(
      layers: [
        ImageLayer(id: 'img-1', imagePath: 'dummy.png'),
        TextLayer(id: 'txt-1', text: 'HELLO', presetStyle: 'Outline'),
      ],
    );

    final result = await renderer.renderToWebp(
      project: project,
      outputWebpPath: outPath,
      tempDirectory: tempDir,
    );

    expect(result, outPath);
    expect(encodedCalled, isTrue);

    await tempDir.delete(recursive: true);
  });
}
