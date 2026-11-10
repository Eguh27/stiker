import 'package:sticker_studio/features/data/app_database.dart';

import 'pack_emojis.dart';

class PackDetails {
  PackDetails({
    required this.id,
    required this.name,
    required this.author,
    required this.trayIconPath,
    required this.version,
    required this.isSynced,
    required List<String> stickerIds,
    List<String> emojis = const [],
  }) : stickerIds = List<String>.unmodifiable(stickerIds),
       emojis = List<String>.unmodifiable(emojis);

  factory PackDetails.fromPack(Pack pack, List<String> stickerIds) {
    return PackDetails(
      id: pack.id,
      name: pack.name,
      author: pack.author,
      trayIconPath: pack.trayIconPath,
      version: pack.version,
      isSynced: pack.isSynced,
      stickerIds: stickerIds,
      emojis: PackEmojis.decode(pack.emojis),
    );
  }

  final String id;
  final String name;
  final String author;
  final String trayIconPath;
  final String version;
  final bool isSynced;
  final List<String> stickerIds;
  final List<String> emojis;

  int get stickerCount => stickerIds.length;
}
