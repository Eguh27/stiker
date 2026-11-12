import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Id stiker yang sedang dipilih di Library. Tidak kosong = mode seleksi.
class StickerSelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String id) {
    final Set<String> next = {...state};
    if (!next.remove(id)) next.add(id);
    state = next;
  }

  void select(String id) => state = {...state, id};

  void selectAll(Iterable<String> ids) => state = ids.toSet();

  void clear() => state = const {};
}

final stickerSelectionProvider =
    NotifierProvider<StickerSelectionNotifier, Set<String>>(
      StickerSelectionNotifier.new,
    );
