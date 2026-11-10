import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sticker_studio/src/rust/api/encode.dart';
import 'package:sticker_studio/src/rust/api/errors.dart';
import 'package:sticker_studio/src/rust/frb_generated.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(RustLib.init);

  testWidgets('FFI returns a typed error for a missing input path', (
    WidgetTester tester,
  ) async {
    await expectLater(
      encodeWhatsappWebp(
        inputPath: '/missing/sticker.png',
        outputPath: '/tmp/sticker.webp',
        targetSizeKb: 100,
      ),
      throwsA(EncodeError.inputNotFound),
    );
  });
}
