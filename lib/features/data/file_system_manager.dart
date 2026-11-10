import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileSystemManager {
  FileSystemManager._(this.appDataDirectory);

  static const String _appDataFolderName = 'app_data';
  static const String _originalsFolderName = 'originals';
  static const String _stickersFolderName = 'stickers';
  static const String _registryFolderName = 'registry';
  static const String databaseFileName = 'sticker_studio.sqlite';

  final Directory appDataDirectory;

  Directory get originalsDirectory => _subdirectoryOf(_originalsFolderName);

  Directory get stickersDirectory => _subdirectoryOf(_stickersFolderName);

  Directory get registryDirectory => _subdirectoryOf(_registryFolderName);

  File get databaseFile =>
      File(p.join(appDataDirectory.path, databaseFileName));

  static Future<FileSystemManager> initialize({
    Directory? baseDirectory,
  }) async {
    final base = baseDirectory ?? await getApplicationSupportDirectory();
    final manager = FileSystemManager._(
      Directory(p.join(base.path, _appDataFolderName)),
    );

    await manager._createDirectories();
    return manager;
  }

  File originalFile(String fileName) => _fileIn(originalsDirectory, fileName);

  File stickerFile(String fileName) => _fileIn(stickersDirectory, fileName);

  File registryFile(String fileName) => _fileIn(registryDirectory, fileName);

  Future<void> _createDirectories() async {
    for (final directory in [
      appDataDirectory,
      originalsDirectory,
      stickersDirectory,
      registryDirectory,
    ]) {
      await _ensureDirectory(directory);
    }
  }

  Directory _subdirectoryOf(String name) =>
      Directory(p.join(appDataDirectory.path, name));

  File _fileIn(Directory directory, String fileName) {
    final isPlainFileName =
        fileName.isNotEmpty &&
        fileName != '.' &&
        fileName != '..' &&
        !p.isAbsolute(fileName) &&
        p.basename(fileName) == fileName;

    if (!isPlainFileName) {
      throw ArgumentError.value(
        fileName,
        'fileName',
        'Must be a plain file name without directory separators',
      );
    }

    return File(p.join(directory.path, fileName));
  }

  Future<void> _ensureDirectory(Directory directory) async {
    final type = await FileSystemEntity.type(
      directory.path,
      followLinks: false,
    );

    if (type == FileSystemEntityType.directory) {
      return;
    }

    if (type == FileSystemEntityType.notFound) {
      await directory.create(recursive: true);
      return;
    }

    throw FileSystemException(
      'Expected a directory but found $type',
      directory.path,
    );
  }
}
