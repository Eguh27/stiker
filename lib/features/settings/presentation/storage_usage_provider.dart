import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/file_system_manager.dart';

/// Total byte yang dipakai folder app_data (stiker, original, registry, DB).
final storageUsageBytesProvider = FutureProvider<int>((ref) async {
  final fs = await FileSystemManager.initialize();
  var total = 0;
  await for (final entity in fs.appDataDirectory.list(recursive: true)) {
    if (entity is File) total += await entity.length();
  }
  return total;
});

String formatBytes(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}
