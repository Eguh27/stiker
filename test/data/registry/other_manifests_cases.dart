import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/registry_engine.dart';

import '../support/manifest_fixtures.dart';
import '../support/registry_test_harness.dart';

void register(RegistryTestHarness harness) {
  group('presets, fonts, themes', () {
    test('membaca ketiga manifest valid', () async {
      await harness.writeManifest(
        RegistryEngine.presetsManifestFileName,
        presetsManifest(),
      );
      await harness.writeManifest(
        RegistryEngine.fontsManifestFileName,
        fontsManifest(),
      );
      await harness.writeManifest(
        RegistryEngine.themesManifestFileName,
        themesManifest(),
      );

      final presets = await harness.engine.loadPresetsManifest();
      final fonts = await harness.engine.loadFontsManifest();
      final themes = await harness.engine.loadThemesManifest();

      expect(presets.presets.single.id, 'bold-outline');
      expect(presets.presets.single.stroke['width'], 4);
      expect(fonts.fonts.first.family, 'Inter');
      expect(fonts.fonts.first.licenseNote, 'OFL-1.1');
      expect(fonts.fonts.last.licenseNote, isNull);
      expect(themes.themes.single.id, 'default');
      expect(
        themes.themes.single.tokens['colors'],
        isA<Map<String, dynamic>>(),
      );
    });

    test('manifest rusak ditolak dengan path field', () async {
      final cases =
          <(String, Map<String, dynamic>, String, Future<Object?> Function())>[
            (
              RegistryEngine.presetsManifestFileName,
              _presetsWithoutShadow(),
              'presets[0].shadow',
              harness.engine.loadPresetsManifest,
            ),
            (
              RegistryEngine.fontsManifestFileName,
              _fontsWithoutFile(),
              'fonts[0].file',
              harness.engine.loadFontsManifest,
            ),
            (
              RegistryEngine.themesManifestFileName,
              _themesWithNonObjectTokens(),
              'themes[0].tokens',
              harness.engine.loadThemesManifest,
            ),
          ];

      for (final (fileName, json, fieldPath, load) in cases) {
        await harness.writeManifest(fileName, json);
        await expectLater(
          load(),
          throwsA(
            harness.manifestError(source: fileName, messageContains: fieldPath),
          ),
        );
      }
    });
  });
}

Map<String, dynamic> _presetsWithoutShadow() {
  return {
    'version': 1,
    'presets': [
      {
        'id': 'bold-outline',
        'name': 'Bold Outline',
        'stroke': {'color': '#111111', 'width': 4},
        'background': {'color': '#FFFFFF'},
      },
    ],
  };
}

Map<String, dynamic> _fontsWithoutFile() {
  return {
    'version': 1,
    'fonts': [
      {'id': 'inter', 'family': 'Inter'},
    ],
  };
}

Map<String, dynamic> _themesWithNonObjectTokens() {
  return {
    'version': 1,
    'themes': [
      {'id': 'default', 'name': 'Sticker Studio', 'tokens': 'oops'},
    ],
  };
}
