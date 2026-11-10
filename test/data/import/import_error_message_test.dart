import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/data/import/import_error_message.dart';
import 'package:sticker_studio/features/data/import/import_exception.dart';
import 'package:sticker_studio/src/rust/api/errors.dart';

void main() {
  test('ImportException memakai pesan aslinya', () {
    expect(
      describeImportError(const ImportException('Gambar rusak')),
      'Gambar rusak',
    );
  });

  test('semua EncodeError punya pesan pengguna', () {
    for (final error in EncodeError.values) {
      expect(describeImportError(error), isNotEmpty);
    }
  });

  test('FileSystemException menjadi pesan salin', () {
    expect(
      describeImportError(const FileSystemException('izin ditolak')),
      contains('Gagal menyalin file'),
    );
  });

  test('semua ResolveError punya pesan pengguna yang jelas', () {
    for (final error in ResolveError.values) {
      expect(describeResolveError(error), isNotEmpty);
    }
    expect(
      describeResolveError(ResolveError.needsLogin),
      'Butuh login ke situs sumber',
    );
    expect(
      describeResolveError(ResolveError.blocked),
      'Situs sumber memblokir unduhan',
    );
  });
}
