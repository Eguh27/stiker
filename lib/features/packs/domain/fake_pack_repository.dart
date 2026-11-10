import '../../library/domain/sticker.dart';
import '../../library/domain/fake_sticker_repository.dart';
import 'pack_repository.dart';
import 'sticker_pack.dart';

/// Fake untuk shell mock & test; diganti Drift nyata oleh BE.
/// Detail per pack memakai pool stiker library untuk placeholder editor.
class FakePackRepository implements PackEditorRepository {
  FakePackRepository({List<StickerPack>? packs, this.errorToThrow})
    : _packs = (packs ?? localPacks).toList(),
      _details = <String, List<Sticker>>{
        for (final StickerPack pack in packs ?? localPacks)
          pack.id: _seedDetails(pack.id, pack.stickerCount),
      };

  FakePackRepository.empty() : this(packs: const []);

  FakePackRepository.failing() : this(errorToThrow: StateError('offline'));

  final List<StickerPack> _packs;
  final Map<String, List<Sticker>> _details;
  final Map<String, List<String>> _emojis = <String, List<String>>{};
  final Object? errorToThrow;

  /// Akses test: data pack terkini setelah Simpan.
  List<StickerPack> get packs => List.unmodifiable(_packs);

  /// Akses test: urutan stiker pack terkini setelah Simpan/reorder.
  List<Sticker> stickersOf(String packId) =>
      List.unmodifiable(_details[packId] ?? const <Sticker>[]);

  static const List<StickerPack> localPacks = [
    StickerPack(id: 'p1', name: 'Daily Mood', stickerCount: 18, isSynced: true),
    StickerPack(
      id: 'p2',
      name: 'Weekend Club',
      stickerCount: 12,
      isSynced: false,
    ),
    StickerPack(
      id: 'p3',
      name: 'Office Signals',
      stickerCount: 7,
      isSynced: true,
    ),
  ];

  static const Duration _mockLatency = Duration(milliseconds: 100);

  /// Placeholder pool: stiker library disirkulasi (data di `stickers` tabel).
  static Sticker seedPlaceholder(String id, int index) {
    const List<Sticker> pool = FakeStickerRepository.localStickers;
    final Sticker base = pool[index % pool.length];
    return Sticker(
      id: id,
      label: base.label,
      colorKind: base.colorKind,
      shape: base.shape,
      sourceLabel: base.sourceLabel,
    );
  }

  static List<Sticker> _seedDetails(String packId, int count) =>
      List.generate(count, (int index) {
        return seedPlaceholder('$packId-s${index + 1}', index);
      });

  StickerPack _find(String packId) {
    final StickerPack? pack = _packs.cast<StickerPack?>().firstWhere(
      (StickerPack? pack) => pack?.id == packId,
      orElse: () => null,
    );
    if (pack == null) throw StateError('Pack $packId tidak ada');
    return pack;
  }

  Future<void> _throwIfUnavailable() async {
    await Future<void>.delayed(_mockLatency);
    final Object? error = errorToThrow;
    if (error != null) throw error;
  }

  @override
  Future<List<StickerPack>> fetchPacks() async {
    await _throwIfUnavailable();
    return _packs.toList();
  }

  @override
  Future<PackDetail> fetchPackDetail(String packId) async {
    await _throwIfUnavailable();
    return PackDetail(
      pack: _find(packId),
      stickers: _details[packId]!.toList(),
      emojiTags: _emojis[packId] ?? const [],
    );
  }

  @override
  Future<PackDetail> createPack({
    required String name,
    required String author,
    List<Sticker> stickers = const [],
    List<String> emojiTags = const [],
  }) async {
    await _throwIfUnavailable();
    final StickerPack created = StickerPack(
      id: 'p${_packs.length + 1}',
      name: name,
      author: author,
      stickerCount: stickers.length,
      isSynced: false,
    );
    _packs.add(created);
    _details[created.id] = stickers.toList();
    _emojis[created.id] = emojiTags.toList();
    return PackDetail(
      pack: created,
      stickers: _details[created.id]!.toList(),
      emojiTags: emojiTags.toList(),
    );
  }

  @override
  Future<void> updatePack({
    required String packId,
    required String name,
    required String author,
    List<String>? emojiTags,
  }) async {
    await _throwIfUnavailable();
    final int index = _packs.indexWhere(
      (StickerPack pack) => pack.id == packId,
    );
    if (index < 0) throw StateError('Pack $packId tidak ada');
    _packs[index] = _packs[index].copyWith(name: name, author: author);
    if (emojiTags != null) {
      _emojis[packId] = emojiTags.toList();
    }
  }

  @override
  Future<void> reorderStickers({
    required String packId,
    required List<String> stickerIds,
  }) async {
    await _throwIfUnavailable();
    final List<Sticker> current = _details[packId]!.toList();
    _details[packId] = [
      for (final String id in stickerIds) _stickerById(id, current),
    ];
    _syncCount(packId);
  }

  Sticker _stickerById(String id, List<Sticker> pool) =>
      pool.firstWhere((Sticker sticker) => sticker.id == id);

  void _syncCount(String packId) {
    final int index = _packs.indexWhere(
      (StickerPack pack) => pack.id == packId,
    );
    if (index >= 0) {
      _packs[index] = _packs[index].copyWith(
        stickerCount: _details[packId]!.length,
      );
    }
  }
}
