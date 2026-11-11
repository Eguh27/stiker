import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_component_themes.dart';
import 'app_spacing.dart';
import 'app_text_theme.dart';

/// Tema Material 3 "Warm Glassmorphism". Latar gradasi digambar oleh
/// `GlassBackground`, jadi scaffold dan appbar dibuat transparan.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness b) {
    final TextTheme textTheme = AppTextTheme.build(c);
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      fontFamily: AppTextTokens.bodyFamily,
      colorScheme: _scheme(c, b),
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: c.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: c.glassFill,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: c.glassBorder),
        ),
      ),
      dividerColor: c.line,
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.accent),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.accent,
        thumbColor: c.accent,
        inactiveTrackColor: c.lineStrong,
      ),
      filledButtonTheme: AppComponentThemes.filledButton(c),
      outlinedButtonTheme: AppComponentThemes.outlinedButton(c),
      inputDecorationTheme: AppComponentThemes.input(c),
      snackBarTheme: AppComponentThemes.snackBar(c),
      bottomSheetTheme: AppComponentThemes.bottomSheet(c),
      dialogTheme: AppComponentThemes.dialog(c),
      switchTheme: AppComponentThemes.switchTheme(c),
    );
  }

  static ColorScheme _scheme(AppColors c, Brightness b) {
    return ColorScheme(
      brightness: b,
      primary: c.accent,
      onPrimary: c.accentText,
      secondary: c.accentSoft,
      onSecondary: c.text,
      error: c.danger,
      onError: c.accentText,
      surface: c.surfaceSolid,
      onSurface: c.text,
      surfaceContainerHighest: c.surfaceMuted,
      outline: c.line,
      outlineVariant: c.lineStrong,
    );
  }
}
