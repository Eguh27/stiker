import 'package:flutter_test/flutter_test.dart';

import 'registry/extractors_manifest_cases.dart' as extractors;
import 'registry/other_manifests_cases.dart' as other_manifests;
import 'registry/registry_errors_cases.dart' as registry_errors;
import 'support/registry_test_harness.dart';

void main() {
  final harness = RegistryTestHarness();

  setUp(harness.setUp);
  tearDown(harness.tearDown);

  extractors.register(harness);
  registry_errors.register(harness);
  other_manifests.register(harness);
}
