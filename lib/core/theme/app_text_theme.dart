import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Skala tipografi Nunito (rounded) untuk semua layar.
class AppTextTheme {
  const AppTextTheme._();

  static TextTheme build(AppColors c) {
    TextStyle style(double size, FontWeight weight, Color color, [double ls = 0]) {
      return TextStyle(
        fontFamily: AppTextTokens.bodyFamily,
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: ls,
        height: 1.25,
      );
    }

    const double tight = AppTextTokens.headingLetterSpacing;
    return TextTheme(
      displayLarge: style(56, FontWeight.w700, c.text, -1.5),
      headlineLarge: style(32, FontWeight.w700, c.text, tight),
      headlineMedium: style(28, FontWeight.w700, c.text, tight),
      titleLarge: style(AppTextTokens.titleSize, FontWeight.w700, c.text, tight),
      titleMedium: style(16, FontWeight.w700, c.text),
      bodyLarge: style(16, FontWeight.w500, c.text),
      bodyMedium: style(AppTextTokens.bodySize, FontWeight.w500, c.text2),
      bodySmall: style(12, FontWeight.w500, c.text3),
      labelLarge: style(14, FontWeight.w700, c.accent),
      labelMedium: style(12, FontWeight.w600, c.text2),
      labelSmall: style(
        AppTextTokens.eyebrowSize,
        AppTextTokens.eyebrowWeight,
        c.text3,
        AppTextTokens.eyebrowLetterSpacing,
      ),
    );
  }
}
