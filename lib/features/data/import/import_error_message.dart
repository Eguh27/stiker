import 'dart:io';

import 'package:sticker_studio/src/rust/api/errors.dart';

import 'import_exception.dart';

String describeImportError(Object error) {
  if (error is ImportException) {
    return error.message;
  }
  if (error is EncodeError) {
    return switch (error) {
      EncodeError.inputNotFound => 'File sumber tidak ditemukan',
      EncodeError.invalidImage => 'Gambar tidak didukung',
      EncodeError.encodeFailed => 'Gagal mengubah gambar menjadi WebP',
      EncodeError.tooLargeAfterQualityLoop =>
        'Ukuran gambar melebihi batas 100 KB',
    };
  }
  if (error is FileSystemException) {
    return 'Gagal menyalin file: ${error.message}';
  }

  return error.toString();
}

String describeResolveError(ResolveError error) {
  return switch (error) {
    ResolveError.needsLogin => 'Butuh login ke situs sumber',
    ResolveError.blocked => 'Situs sumber memblokir unduhan',
    ResolveError.notFound => 'Gambar tidak ditemukan di tautan',
    ResolveError.unsupportedType => 'Tautan atau jenis media tidak didukung',
  };
}
