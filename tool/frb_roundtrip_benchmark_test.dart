/// Host baseline for the Flutter <-> Rust round-trip.
///
/// Run `cargo build --release --manifest-path rust/Cargo.toml` first, then
/// `flutter test tool/frb_roundtrip_benchmark_test.dart --reporter expanded`.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/src/rust/api/encode.dart';
import 'package:sticker_studio/src/rust/api/errors.dart';
import 'package:sticker_studio/src/rust/frb_generated.dart';

const int warmupIterations = 100;
const int measuredIterations = 1000;

Future<void> callEncode() async {
  try {
    await encodeWhatsappWebp(
      inputPath: '/missing/sticker.png',
      outputPath: '/tmp/sticker.webp',
      targetSizeKb: 100,
    );
    throw StateError('stub unexpectedly succeeded');
  } on EncodeError catch (error) {
    if (error != EncodeError.inputNotFound) {
      throw StateError('unexpected FFI error: $error');
    }
  }
}

void main() {
  setUpAll(RustLib.init);

  test('FFI round-trip baseline', () async {
    for (var i = 0; i < warmupIterations; i++) {
      await callEncode();
    }

    final samples = <int>[];
    for (var i = 0; i < measuredIterations; i++) {
      final stopwatch = Stopwatch()..start();
      await callEncode();
      stopwatch.stop();
      samples.add(stopwatch.elapsedMicroseconds);
    }
    samples.sort();

    final total = samples.fold<int>(0, (sum, value) => sum + value);
    final average = total / samples.length;
    // ignore: avoid_print
    print(
      'FRB round-trip (host linux): avg=${average.toStringAsFixed(1)}us '
      'p50=${samples[samples.length ~/ 2]}us '
      'p95=${samples[(samples.length * 0.95).floor()]}us '
      'min=${samples.first}us max=${samples.last}us '
      'n=$measuredIterations',
    );
  });
}
