import 'dart:math';

String createImportId({Random? random}) {
  final source = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => source.nextInt(256));

  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}
