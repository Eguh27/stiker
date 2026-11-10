import 'dart:convert';

import '../../packs/domain/pack_limits.dart';
import 'pack_validation.dart';

/// Serialisasi, deserialisasi, dan validasi tag emoji WhatsApp (maks 3).
class PackEmojis {
  const PackEmojis._();

  static String encode(List<String> emojis) => jsonEncode(emojis);

  static List<String> decode(String raw) {
    if (raw.trim().isEmpty) return const [];
    try {
      final Object? parsed = jsonDecode(raw);
      if (parsed is List) {
        return List<String>.unmodifiable(parsed.map((item) => item.toString()));
      }
    } on FormatException {
      return const [];
    }
    return const [];
  }

  static void validate(List<String> emojis) {
    if (emojis.length > PackLimits.maxEmojiTags) {
      throw PackValidationException(
        'Emoji maksimal ${PackLimits.maxEmojiTags} (saat ini ${emojis.length}).',
      );
    }
    if (emojis.toSet().length != emojis.length) {
      throw const PackValidationException('Emoji tidak boleh duplikat.');
    }
    for (final String emoji in emojis) {
      if (!PackLimits.emojiTagOptions.contains(emoji)) {
        throw PackValidationException(
          'Emoji "$emoji" tidak valid. Pilihan: '
          '${PackLimits.emojiTagOptions.join(', ')}.',
        );
      }
    }
  }

  static bool hasSameEmojis(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
