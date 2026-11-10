import 'dart:io';

import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/file_system_manager.dart';
import 'package:sticker_studio/src/rust/api/errors.dart';
import 'package:sticker_studio/src/rust/api/resolve.dart';

import 'dart_media_resolver.dart';
import 'import_error_message.dart';
import 'import_exception.dart';
import 'url_import_queue_store.dart';

typedef ExternalMediaResolver = Future<String> Function({
  required String url,
  required String outputPath,
  required String extractorsManifestPath,
});

class UrlImportRunner {
  UrlImportRunner({
    required this.store,
    required this.fileSystemManager,
    required this.extractorsManifestPath,
    ExternalMediaResolver? resolver,
    String Function(ResolveError error)? describeError,
  }) : _resolver = resolver ?? resolveExternalMedia,
       _describeError = describeError ?? describeResolveError;

  final UrlImportQueueStore store;
  final FileSystemManager fileSystemManager;
  final String extractorsManifestPath;
  final ExternalMediaResolver _resolver;
  final String Function(ResolveError error) _describeError;

  Future<int> processPending() async {
    await store.resetInterrupted();
    var processed = 0;

    while (true) {
      final entry = await store.fetchNextPending();
      if (entry == null) {
        return processed;
      }
      await _processEntry(entry);
      processed++;
    }
  }

  Future<void> _processEntry(ImportQueueEntry entry) async {
    final sourceUrl = entry.sourceUrl;
    if (sourceUrl == null) {
      await store.markFailed(entry.id, 'Tautan sumber tidak tersedia');
      return;
    }

    final File output;
    try {
      output = fileSystemManager.originalFile(
        '${entry.id}${_downloadExtension(sourceUrl)}',
      );
    } on ArgumentError {
      await store.markFailed(entry.id, 'ID antrean tidak valid');
      return;
    }

    try {
      await store.markDownloading(entry.id);
      var downloaded = false;
      try {
        await _resolver(
          url: sourceUrl,
          outputPath: output.path,
          extractorsManifestPath: extractorsManifestPath,
        );
        downloaded = await output.exists() && await output.length() > 0;
      } on ResolveError {
        rethrow;
      } catch (_) {
        downloaded = false;
      }

      if (!downloaded) {
        downloaded = await downloadMediaWithDart(
          url: sourceUrl,
          outputPath: output.path,
        );
      }

      if (!downloaded || !await output.exists() || await output.length() == 0) {
        throw const ImportException('Gambar tidak ditemukan di tautan');
      }
      await store.markDownloaded(entry.id, output.path);
    } on ResolveError catch (error) {
      await _discard(output);
      await store.markFailed(entry.id, _describeError(error));
    } catch (error) {
      await _discard(output);
      await store.markFailed(entry.id, describeImportError(error));
    }
  }

  Future<void> _discard(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } on FileSystemException {
      // Unduhan gagal tetap harus tercatat; file sisa dibersihkan lain waktu.
    }
  }
}

String _downloadExtension(String sourceUrl) {
  final path = Uri.tryParse(sourceUrl)?.path.toLowerCase() ?? '';
  for (final extension in const ['.jpg', '.jpeg', '.png', '.webp']) {
    if (path.endsWith(extension)) {
      return extension;
    }
  }
  return '.img';
}
