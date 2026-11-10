/// Aturan pack WhatsApp dari `design/tokens.json::constraints.whatsapp`
/// (3..30 stiker, teks maks 28, tag emoji maks 3).
class PackLimits {
  const PackLimits._();

  static const int minStickers = 3;
  static const int maxStickers = 30;
  static const int maxEmojiTags = 3;
  static const int textMaxLength = 28;

  /// Pilihan tag emoji seperti demo `App.tsx::PackEditor`.
  static const List<String> emojiTagOptions = <String>[
    'Smile',
    'Love',
    'Party',
    'Work',
  ];
}
