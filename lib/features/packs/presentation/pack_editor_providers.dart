import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/pack_editor_state.dart';
import '../domain/pack_limits.dart';
import '../domain/pack_repository.dart';
import '../domain/sticker_pack.dart';
import '../../library/domain/fake_sticker_repository.dart';
import '../../library/domain/sticker.dart';
import 'pack_providers.dart';

/// Editor per kurung (arg = packId; null = buat pack baru).
final packEditorProvider =
    NotifierProvider.family<PackEditorNotifier, PackEditorState, String?>(
      PackEditorNotifier.new,
    );

class PackEditorNotifier extends Notifier<PackEditorState> {
  PackEditorNotifier(this._packId);

  final String? _packId;

  @override
  PackEditorState build() {
    Future<void>.microtask(_load);
    return _packId == null
        ? PackEditorState.ready(
            pack: StickerPack.empty,
            stickers: const [],
            emojiTags: const [],
          )
        : const PackEditorState.loading();
  }

  Future<void> _load() async {
    final String? packId = _packId;
    if (packId == null) return;
    try {
      final PackDetail detail = await ref
          .read(packRepositoryProvider)
          .fetchPackDetail(packId);
      state = PackEditorState.ready(
        pack: detail.pack,
        stickers: detail.stickers,
        emojiTags: detail.emojiTags,
      );
    } on Object {
      state = const PackEditorState.error();
    }
  }

  /// Ulang muat data pack; dipakai tombol Coba lagi pada ErrorState.
  Future<void> reload() async {
    if (_packId == null) return;
    state = const PackEditorState.loading();
    await _load();
  }

  void rename(String value) => _editPack(name: _cap(value));

  void setAuthor(String value) => _editPack(author: _cap(value));

  void addStickers(List<Sticker> toAdd) {
    if (!state.isReady || toAdd.isEmpty) return;
    final existingIds = state.stickers.map((s) => s.id).toSet();
    final unique = toAdd.where((s) => !existingIds.contains(s.id)).toList();
    final remaining = PackLimits.maxStickers - state.stickers.length;
    final allowed = unique.take(remaining).toList();
    if (allowed.isEmpty) return;
    state = state.copyWith(stickers: [...state.stickers, ...allowed]);
  }

  void removeSticker(int index) {
    if (!state.isReady || index < 0 || index >= state.stickers.length) return;
    final next = [...state.stickers]..removeAt(index);
    state = state.copyWith(stickers: next);
  }

  /// Tambah draft stiker: id draft unik, tampilan pool library disirkulasi.
  /// Mock FE — nanti diganti picker library berisi stiker asli.
  void addSticker() {
    if (!state.isReady || !state.canAddSticker) return;
    const List<Sticker> pool = FakeStickerRepository.localStickers;
    final Sticker base = pool[state.stickers.length % pool.length];
    state = state.copyWith(
      stickers: [
        ...state.stickers,
        Sticker(
          id: 'draft-${state.stickers.length}',
          label: base.label,
          colorKind: base.colorKind,
          shape: base.shape,
          sourceLabel: base.sourceLabel,
        ),
      ],
    );
  }

  /// Reorder dari drag-and-drop grid (index lama/index baru).
  void moveSticker(int oldIndex, int newIndex) {
    final List<Sticker> next = [...state.stickers];
    final Sticker moved = next.removeAt(oldIndex);
    next.insert(newIndex, moved);
    state = state.copyWith(stickers: next);
  }

  /// Toggle tag emoji; ke-4 tidak ditambahkan (aturan maks 3).
  void toggleEmojiTag(String tag) {
    if (!state.isReady) return;
    final List<String> next = [...state.emojiTags];
    if (next.contains(tag)) {
      next.remove(tag);
    } else if (state.canAddEmojiTag) {
      next.add(tag);
    } else {
      return;
    }
    state = state.copyWith(emojiTags: next);
  }

  String _cap(String value) {
    if (value.length <= PackLimits.textMaxLength) return value;
    return value.substring(0, PackLimits.textMaxLength);
  }

  void _editPack({String? name, String? author}) {
    if (!state.isReady) return;
    state = state.copyWith(
      pack: state.pack!.copyWith(name: name, author: author),
    );
  }

  /// Simpan pack ke repository; return true bila sukses.
  Future<bool> save() async {
    final PackEditorState current = state;
    if (!current.isReady || current.isSaving) return false;
    state = current.copyWith(isSaving: true);
    final PackEditorRepository repository = ref.read(packRepositoryProvider);
    try {
      if (_packId == null) {
        await repository.createPack(
          name: _saveName(current.pack!),
          author: current.pack!.author.trim(),
          stickers: current.stickers,
          emojiTags: current.emojiTags,
        );
      } else {
        await repository.updatePack(
          packId: _packId,
          name: _saveName(current.pack!),
          author: current.pack!.author.trim(),
          emojiTags: current.emojiTags,
        );
        await repository.reorderStickers(
          packId: _packId,
          stickerIds: [
            for (final Sticker sticker in current.stickers) sticker.id,
          ],
        );
      }
    } on Object {
      state = state.copyWith(isSaving: false);
      return false;
    }
    state = state.copyWith(isSaving: false);
    ref.invalidate(packListProvider);
    return true;
  }

  String _saveName(StickerPack pack) {
    final String trimmed = pack.name.trim();
    return trimmed.isEmpty ? 'Tanpa nama' : trimmed;
  }
}
