import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/registry_engine.dart';

import '../support/registry_test_harness.dart';

void register(RegistryTestHarness harness) {
  group('registry errors', () {
    test('manifest hilang menghasilkan error yang jelas', () async {
      await expectLater(
        harness.engine.loadExtractorsManifest(),
        throwsA(
          harness.manifestError(
            source: RegistryEngine.extractorsManifestFileName,
            messageContains: 'file not found',
          ),
        ),
      );
    });

    test('JSON rusak menghasilkan error yang jelas', () async {
      await harness.writeRaw(
        RegistryEngine.extractorsManifestFileName,
        '{"version": 1,',
      );

      await expectLater(
        harness.engine.loadExtractorsManifest(),
        throwsA(
          harness.manifestError(
            source: RegistryEngine.extractorsManifestFileName,
            messageContains: 'invalid JSON',
          ),
        ),
      );
    });

    test('root bukan object ditolak', () async {
      await harness.writeRaw(RegistryEngine.extractorsManifestFileName, '[]');

      await expectLater(
        harness.engine.loadExtractorsManifest(),
        throwsA(
          harness.manifestError(
            source: RegistryEngine.extractorsManifestFileName,
            messageContains: 'root must be a JSON object',
          ),
        ),
      );
    });
  });
}
