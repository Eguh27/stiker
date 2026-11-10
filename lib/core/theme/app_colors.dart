import 'package:flutter/material.dart';

/// Warna dari design/tokens.json + index.css (light & dark).
/// Semua hex/rgba diterjemahkan sekali di sini; widget hanya pakai token.
class AppColors {
  const AppColors({
    required this.canvas,
    required this.bg,
    required this.surface,
    required this.surfaceSolid,
    required this.surfaceMuted,
    required this.line,
    required this.lineStrong,
    required this.text,
    required this.text2,
    required this.text3,
    required this.accent,
    required this.accentSoft,
    required this.accentText,
    required this.success,
    required this.successSoft,
    required this.danger,
    required this.dangerSoft,
    required this.warning,
    required this.warningSoft,
    required this.whatsapp,
    required this.onWhatsapp,
    required this.stickerLavender,
    required this.stickerPeach,
    required this.stickerMint,
    required this.stickerBlue,
    required this.stickerYellow,
    required this.stickerPink,
  });

  final Color canvas;
  final Color bg;
  final Color surface;
  final Color surfaceSolid;
  final Color surfaceMuted;
  final Color line;
  final Color lineStrong;
  final Color text;
  final Color text2;
  final Color text3;
  final Color accent;
  final Color accentSoft;
  final Color accentText;
  final Color success;
  final Color successSoft;
  final Color danger;
  final Color dangerSoft;
  final Color warning;
  final Color warningSoft;
  final Color whatsapp;
  final Color onWhatsapp;
  final Color stickerLavender;
  final Color stickerPeach;
  final Color stickerMint;
  final Color stickerBlue;
  final Color stickerYellow;
  final Color stickerPink;

  static const AppColors light = AppColors(
    canvas: Color(0xFFE1DBD6),
    bg: Color(0xFFF9F6F2),
    surface: Color(0xB8FFFFFF),
    surfaceSolid: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEEEBE7),
    line: Color(0x1A2E2A27),
    lineStrong: Color(0x2E2E2A27),
    text: Color(0xFF282522),
    text2: Color(0xFF6E6862),
    text3: Color(0xFF918A84),
    accent: Color(0xFF7463B5),
    accentSoft: Color(0xFFE8E1FF),
    accentText: Color(0xFFFFFFFF),
    success: Color(0xFF4F8066),
    successSoft: Color(0xFFE1EEE7),
    danger: Color(0xFFA65454),
    dangerSoft: Color(0xFFF7E5E3),
    warning: Color(0xFF9A743E),
    warningSoft: Color(0xFFF3EAD8),
    whatsapp: Color(0xFF287D4F),
    onWhatsapp: Color(0xFFFFFFFF),
    stickerLavender: Color(0xFFCFC4F4),
    stickerPeach: Color(0xFFEFBCA9),
    stickerMint: Color(0xFFB9D8C5),
    stickerBlue: Color(0xFFB9D3E1),
    stickerYellow: Color(0xFFEDD88B),
    stickerPink: Color(0xFFE9BDCD),
  );

  static const AppColors dark = AppColors(
    canvas: Color(0xFF23211F),
    bg: Color(0xFF1B1A19),
    surface: Color(0xC22F2D2B),
    surfaceSolid: Color(0xFF302E2C),
    surfaceMuted: Color(0xFF292725),
    line: Color(0x17FFFFFF),
    lineStrong: Color(0x29FFFFFF),
    text: Color(0xFFF5F1ED),
    text2: Color(0xFFBCB5AF),
    text3: Color(0xFF88817B),
    accent: Color(0xFFAA98ED),
    accentSoft: Color(0xFF3F3859),
    accentText: Color(0xFF1F1A2D),
    success: Color(0xFF85BA9B),
    successSoft: Color(0xFF263D31),
    danger: Color(0xFFE0928E),
    dangerSoft: Color(0xFF4B2E2D),
    warning: Color(0xFFD6AD70),
    warningSoft: Color(0xFF443724),
    whatsapp: Color(0xFF287D4F),
    onWhatsapp: Color(0xFFFFFFFF),
    stickerLavender: Color(0xFFCFC4F4),
    stickerPeach: Color(0xFFEFBCA9),
    stickerMint: Color(0xFFB9D8C5),
    stickerBlue: Color(0xFFB9D3E1),
    stickerYellow: Color(0xFFEDD88B),
    stickerPink: Color(0xFFE9BDCD),
  );
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).brightness == Brightness.dark
      ? AppColors.dark
      : AppColors.light;
}
