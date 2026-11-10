import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Material 3 theme dari tokens.json. Warna/size hanya dari token.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness b) {
    final scheme = ColorScheme(
      brightness: b,
      primary: c.accent,
      onPrimary: c.accentText,
      secondary: c.accentSoft,
      onSecondary: c.text,
      error: c.danger,
      onError: c.dangerSoft,
      surface: c.surfaceSolid,
      onSurface: c.text,
      surfaceContainerHighest: c.surfaceMuted,
      outline: c.line,
      outlineVariant: c.lineStrong,
    );
    final textTheme = TextTheme(
      titleLarge: TextStyle(
        fontFamily: AppTextTokens.headingFamily,
        fontSize: AppTextTokens.titleSize,
        fontWeight: FontWeight.w700,
        color: c.text,
        letterSpacing: AppTextTokens.headingLetterSpacing,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppTextTokens.bodyFamily,
        fontSize: AppTextTokens.bodySize,
        color: c.text2,
      ),
      bodySmall: TextStyle(
        fontFamily: AppTextTokens.bodyFamily,
        fontSize: 11,
        color: c.text3,
      ),
      labelSmall: TextStyle(
        fontFamily: AppTextTokens.bodyFamily,
        fontSize: AppTextTokens.eyebrowSize,
        fontWeight: AppTextTokens.eyebrowWeight,
        color: c.text3,
        letterSpacing: AppTextTokens.eyebrowLetterSpacing,
      ),
      labelLarge: TextStyle(
        fontFamily: AppTextTokens.bodyFamily,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: c.accent,
      ),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: c.bg,
      fontFamilyFallback: const ['sans-serif'],
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: c.text),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surfaceSolid.withValues(alpha: 0.8),
        indicatorColor: c.accentSoft,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: AppTextTokens.bodyFamily,
            fontSize: AppTextTokens.navLabelSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: c.text3, size: AppLayout.iconGridSize),
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: c.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(c.accent),
          foregroundColor: WidgetStatePropertyAll(c.accentText),
          minimumSize: const WidgetStatePropertyAll(
            Size(0, AppLayout.primaryButtonMinHeight),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.pill),
          ),
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              fontFamily: AppTextTokens.bodyFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.accentText,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
          textStyle: TextStyle(
            fontFamily: AppTextTokens.bodyFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          textStyle: TextStyle(
            fontFamily: AppTextTokens.bodyFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: c.text),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accent,
        foregroundColor: c.accentText,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
      ),
      dividerTheme: DividerThemeData(color: c.line, thickness: 1),
    );
  }
}
