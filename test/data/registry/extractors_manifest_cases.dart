import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/registry_engine.dart';

import '../support/manifest_fixtures.dart';
import '../support/registry_test_harness.dart';

void register(RegistryTestHarness harness) {
  group('extractors manifest', () {
    test('membaca manifest valid', () async {
      await harness.writeManifest(
        RegistryEngine.extractorsManifestFileName,
        extractorsManifest(),
      );

      final manifest = await harness.engine.loadExtractorsManifest();

      expect(manifest.version, 1);
      expect(manifest.extractors, hasLength(2));
      expect(manifest.extractors.first.domains, ['pinterest.com', 'pin.it']);
      expect(manifest.extractors.first.strategy, 'og_image');
      expect(manifest.extractors.first.needsLogin, isFalse);
    });

    test(
      'aturan domain berasal dari manifest, bukan hardcode Pinterest',
      () async {
        await harness.writeManifest(
          RegistryEngine.extractorsManifestFileName,
          extractorsManifest(
            extractors: [
              {
                'domain': ['example.org'],
                'strategy': 'og_image',
                'needs_login': true,
              },
            ],
          ),
        );

        final manifest = await harness.engine.loadExtractorsManifest();
        final matched = manifest.ruleFor(
          Uri.parse('https://cdn.example.org/pin/1'),
        );

        expect(matched, isNotNull);
        expect(matched!.needsLogin, isTrue);
        expect(
          manifest.ruleFor(Uri.parse('https://www.pinterest.com/pin/1')),
          isNull,
        );
        expect(
          manifest.ruleFor(Uri.parse('https://notexample.org/pin/1')),
          isNull,
        );
      },
    );

    test('menolak versi manifest yang tidak didukung', () async {
      await harness.writeManifest(
        RegistryEngine.extractorsManifestFileName,
        extractorsManifest(version: 2),
      );

      await expectLater(
        harness.engine.loadExtractorsManifest(),
        throwsA(
          harness.manifestError(
            source: RegistryEngine.extractorsManifestFileName,
            messageContains: 'unsupported version',
          ),
        ),
      );
    });

    test('melaporkan field yang salah beserta path-nya', () async {
      await harness.writeManifest(
        RegistryEngine.extractorsManifestFileName,
        extractorsManifest(
          extractors: [
            {
              'domain': ['example.org'],
              'strategy': 'og_image',
              'needs_login': 'yes',
            },
          ],
        ),
      );

      await expectLater(
        harness.engine.loadExtractorsManifest(),
        throwsA(
          harness.manifestError(
            source: RegistryEngine.extractorsManifestFileName,
            messageContains: 'extractors[0].needs_login',
          ),
        ),
      );
    });

    test('menolak domain kosong atau bukan hostname', () async {
      for (final domains in <List<String>>[
        <String>[],
        ['https://example.org/path'],
      ]) {
        await harness.writeManifest(
          RegistryEngine.extractorsManifestFileName,
          extractorsManifest(
            extractors: [
              {'domain': domains, 'strategy': 'og_image', 'needs_login': false},
            ],
          ),
        );

        await expectLater(
          harness.engine.loadExtractorsManifest(),
          throwsA(
            harness.manifestError(
              source: RegistryEngine.extractorsManifestFileName,
              messageContains: 'extractors[0].domain',
            ),
          ),
        );
      }
    });
  });
}
