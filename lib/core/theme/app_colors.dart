import 'package:flutter/material.dart';

import 'app_palettes.dart';

/// Token warna "Warm Glassmorphism". Nilai ada di `app_palettes.dart`.
class AppColors {
  const AppColors({
    required this.canvas,
    required this.bg,
    required this.bgTop,
    required this.bgMid,
    required this.bgBottom,
    required this.glow,
    required this.surface,
    required this.surfaceSolid,
    required this.surfaceMuted,
    required this.glassFill,
    required this.glassBorder,
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
  final Color bgTop;
  final Color bgMid;
  final Color bgBottom;
  final Color glow;
  final Color surface;
  final Color surfaceSolid;
  final Color surfaceMuted;
  final Color glassFill;
  final Color glassBorder;
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

  static const AppColors light = lightPalette;
  static const AppColors dark = darkPalette;
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).brightness == Brightness.dark
      ? AppColors.dark
      : AppColors.light;
}
