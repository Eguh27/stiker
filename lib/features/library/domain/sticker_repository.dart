import 'sticker.dart';

/// Interface library. FFI DB (`db-schema.md:stickers`) diganti lewat kontrak
/// ini; presentation hanya bergantung pada interface, bukan ke `data/`.
abstract class StickerRepository {
  Future<List<Sticker>> fetchStickers();
}
