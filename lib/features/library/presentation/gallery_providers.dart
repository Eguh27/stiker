import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/sticker.dart';
import 'sticker_providers.dart';

final galleryPhotosProvider = Provider<AsyncValue<List<Sticker>>>((ref) {
  final AsyncValue<List<Sticker>> stickers = ref.watch(stickerListProvider);
  return stickers.whenData(
    (List<Sticker> list) => list.isEmpty
        ? const <Sticker>[]
        : List<Sticker>.generate(12, (int index) => list[index % list.length]),
  );
});

class GallerySelectionNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => const <int>{0, 2, 5};

  void toggle(int index) {
    final Set<int> next = Set<int>.of(state);
    if (next.contains(index)) {
      next.remove(index);
    } else {
      next.add(index);
    }
    state = next;
  }

  void selectAll() {
    state = <int>{for (int index = 0; index < 12; index++) index};
  }

  void clearAll() {
    state = const <int>{};
  }
}

final gallerySelectionProvider =
    NotifierProvider<GallerySelectionNotifier, Set<int>>(
      GallerySelectionNotifier.new,
    );
