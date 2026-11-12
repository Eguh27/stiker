import 'sticker.dart';
import 'sticker_repository.dart';

/// Fake untuk shell mock & widget test; diganti Drift nyata oleh BE.
class FakeStickerRepository implements StickerRepository {
  FakeStickerRepository({List<Sticker>? stickers, this.errorToThrow})
    : stickers = stickers ?? FakeStickerRepository.localStickers;

  FakeStickerRepository.empty() : this(stickers: const []);

  FakeStickerRepository.failing() : this(errorToThrow: StateError('offline'));

  List<Sticker> stickers;
  final Object? errorToThrow;

  static const List<Sticker> localStickers = [
    Sticker(
      id: 's1',
      label: 'OK!',
      colorKind: StickerColorKind.lavender,
      shape: StickerShape.burst,
      sourceLabel: 'Fun pack',
    ),
    Sticker(
      id: 's2',
      label: 'YAY',
      colorKind: StickerColorKind.peach,
      shape: StickerShape.flower,
      sourceLabel: 'Daily',
    ),
    Sticker(
      id: 's3',
      label: 'HI!',
      colorKind: StickerColorKind.mint,
      shape: StickerShape.blob,
      sourceLabel: 'Imported',
    ),
    Sticker(
      id: 's4',
      label: 'WOW',
      colorKind: StickerColorKind.blue,
      shape: StickerShape.cloud,
      sourceLabel: 'Daily',
    ),
    Sticker(
      id: 's5',
      label: 'LOL',
      colorKind: StickerColorKind.yellow,
      shape: StickerShape.burst,
      sourceLabel: 'Fun pack',
    ),
    Sticker(
      id: 's6',
      label: 'NICE',
      colorKind: StickerColorKind.pink,
      shape: StickerShape.blob,
      sourceLabel: 'Daily',
    ),
    Sticker(
      id: 's7',
      label: 'GO!',
      colorKind: StickerColorKind.mint,
      shape: StickerShape.flower,
      sourceLabel: 'Imported',
    ),
    Sticker(
      id: 's8',
      label: 'YES',
      colorKind: StickerColorKind.lavender,
      shape: StickerShape.cloud,
      sourceLabel: 'Daily',
    ),
  ];

  @override
  Future<List<Sticker>> fetchStickers() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final Object? error = errorToThrow;
    if (error != null) throw error;
    return stickers;
  }

  @override
  Future<int> deleteStickers(Iterable<String> ids) async {
    final Set<String> idSet = ids.toSet();
    final int before = stickers.length;
    stickers = [
      for (final Sticker s in stickers)
        if (!idSet.contains(s.id)) s,
    ];
    return before - stickers.length;
  }
}
