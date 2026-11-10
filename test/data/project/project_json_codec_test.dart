import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/project/project_json_codec.dart';
import 'package:sticker_studio/features/editor/domain/scene_layer.dart';
import 'package:sticker_studio/features/editor/domain/scene_project.dart';
import 'package:sticker_studio/features/editor/domain/text_layer.dart';

void main() {
  group('ProjectJsonCodec', () {
    test('encode dan decode menghasilkan project identik (lossless)', () {
      const original = SceneProject(
        version: 1,
        canvasWidth: 512,
        canvasHeight: 512,
        layers: [
          ImageLayer(
            id: 'img-1',
            imagePath: '/path/to/img.webp',
            transform: LayerTransform(
              x: 200,
              y: 200,
              scale: 1.2,
              rotation: 0.1,
            ),
          ),
          TextLayer(
            id: 'txt-1',
            text: 'HELLO!',
            fontFamily: 'Inter',
            fontSize: 42,
            color: '#ffffff',
            presetStyle: 'Outline',
            styleColor: '#000000',
            transform: LayerTransform(
              x: 256,
              y: 350,
              scale: 1.0,
              rotation: 0.0,
            ),
          ),
        ],
      );

      final encoded = ProjectJsonCodec.encode(original);
      final decoded = ProjectJsonCodec.decode(encoded);

      expect(decoded.version, 1);
      expect(decoded.canvasWidth, 512);
      expect(decoded.canvasHeight, 512);
      expect(decoded.layers, hasLength(2));

      final img = decoded.layers[0] as ImageLayer;
      expect(img.id, 'img-1');
      expect(img.imagePath, '/path/to/img.webp');
      expect(img.transform.scale, 1.2);

      final txt = decoded.layers[1] as TextLayer;
      expect(txt.id, 'txt-1');
      expect(txt.text, 'HELLO!');
      expect(txt.fontFamily, 'Inter');
      expect(txt.presetStyle, 'Outline');
    });

    test('decode menolak json kosong atau format rusak', () {
      expect(
        () => ProjectJsonCodec.decode(''),
        throwsA(isA<ProjectCodecException>()),
      );
      expect(
        () => ProjectJsonCodec.decode('{invalid json}'),
        throwsA(isA<ProjectCodecException>()),
      );
      expect(
        () => ProjectJsonCodec.decode('{"canvas": {}}'),
        throwsA(isA<ProjectCodecException>()),
      );
    });
  });
}
