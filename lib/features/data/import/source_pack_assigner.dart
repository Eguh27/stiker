import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/packs/domain/pack_limits.dart';

/// Memasukkan stiker hasil impor ke pack otomatis sesuai sumbernya.
/// Pack penuh (30 stiker, batas WhatsApp) diganti pack lanjutan "Nama 2", dst.
class SourcePackAssigner {
  SourcePackAssigner(this._database);

  final AppDatabase _database;

  Future<void> assign(ImportQueueEntry item, String trayIconPath) async {
    final baseName = _baseName(item);
    final pack = await _openPack(baseName, trayIconPath);
    final count = await _countStickers(pack.id);
    await _database
        .into(_database.packStickers)
        .insertOnConflictUpdate(
          PackStickersCompanion.insert(
            packId: pack.id,
            stickerId: item.id,
            position: count,
          ),
        );
  }

  Future<Pack> _openPack(String baseName, String trayIconPath) async {
    for (var part = 1; ; part++) {
      final name = part == 1 ? baseName : '$baseName $part';
      final existing = await (_database.select(
        _database.packs,
      )..where((t) => t.name.equals(name))).getSingleOrNull();
      if (existing == null) return _createPack(name, trayIconPath);
      if (await _countStickers(existing.id) < PackLimits.maxStickers) {
        return existing;
      }
    }
  }

  Future<Pack> _createPack(String name, String trayIconPath) async {
    final now = DateTime.now();
    final id = 'pack-${name.toLowerCase().replaceAll(' ', '-')}-'
        '${now.millisecondsSinceEpoch}';
    await _database
        .into(_database.packs)
        .insert(
          PacksCompanion.insert(
            id: id,
            name: name,
            author: 'Sticker Studio',
            trayIconPath: trayIconPath,
            version: '1',
            isSynced: false,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (_database.select(_database.packs)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  Future<int> _countStickers(String packId) async {
    final rows = await (_database.select(
      _database.packStickers,
    )..where((t) => t.packId.equals(packId))).get();
    return rows.length;
  }

  String _baseName(ImportQueueEntry item) {
    final url = item.sourceUrl?.toLowerCase() ?? '';
    if (url.contains('pinterest') || item.sourceType == SourceType.pinterest) {
      return 'Pinterest';
    }
    if (url.contains('instagram')) return 'Instagram';
    if (url.contains('twitter') || url.contains('x.com')) return 'Twitter';
    if (item.sourceType == SourceType.galleryShare ||
        item.sourceType == SourceType.galleryPicker) {
      return 'Galeri';
    }
    return _hostName(url) ?? 'Unduhan';
  }

  String? _hostName(String url) {
    final host = Uri.tryParse(url)?.host ?? '';
    if (host.isEmpty) return null;
    final parts = host.split('.');
    final name = parts.length >= 2 ? parts[parts.length - 2] : host;
    return name[0].toUpperCase() + name.substring(1);
  }
}
