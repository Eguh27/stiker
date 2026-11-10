import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/features/library/domain/sticker.dart';
import 'package:sticker_studio/features/packs/domain/pack_editor_state.dart';
import 'package:sticker_studio/features/packs/domain/pack_limits.dart';
import 'package:sticker_studio/features/packs/domain/sticker_pack.dart';

PackEditorState readyState({
  required int stickerCount,
  required List<String> emojiTags,
}) {
  return PackEditorState.ready(
    pack: StickerPack.empty,
    stickers: [
      for (int index = 0; index < stickerCount; index++)
        Sticker(
          id: 's$index',
          label: '$index',
          colorKind: StickerColorKind.mint,
          shape: StickerShape.blob,
        ),
    ],
    emojiTags: emojiTags,
  );
}

void main() {
  test('publish hanya saat stiker 3..30', () {
    expect(
      readyState(stickerCount: 2, emojiTags: const []).isPublishable,
      isFalse,
    );
    expect(
      readyState(stickerCount: 3, emojiTags: const []).isPublishable,
      isTrue,
    );
    expect(
      readyState(stickerCount: 30, emojiTags: const []).isPublishable,
      isTrue,
    );
    expect(
      readyState(stickerCount: 31, emojiTags: const []).isPublishable,
      isFalse,
    );
  });

  test('canAddSticker true sebelum 30', () {
    expect(
      readyState(stickerCount: 29, emojiTags: const []).canAddSticker,
      isTrue,
    );
    expect(
      readyState(stickerCount: 30, emojiTags: const []).canAddSticker,
      isFalse,
    );
  });

  test('tag emoji maks ${PackLimits.maxEmojiTags}', () {
    expect(
      readyState(stickerCount: 0, emojiTags: const ['Smile']).canAddEmojiTag,
      isTrue,
    );
    expect(
      readyState(
        stickerCount: 0,
        emojiTags: ['Smile', 'Love', 'Party'],
      ).canAddEmojiTag,
      isFalse,
    );
  });

  test('displayName kosong memakai Tanpa nama', () {
    expect(StickerPack.empty.name, isEmpty);
    expect(
      readyState(stickerCount: 0, emojiTags: const []).displayName,
      'Tanpa nama',
    );
  });
}
