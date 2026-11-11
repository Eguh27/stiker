import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Tema komponen Material yang dipakai bersama oleh seluruh layar.
class AppComponentThemes {
  const AppComponentThemes._();

  static const _pill = RoundedRectangleBorder(borderRadius: AppRadius.pill);

  static FilledButtonThemeData filledButton(AppColors c) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.accent,
        foregroundColor: c.accentText,
        minimumSize: const Size(0, AppLayout.primaryButtonMinHeight),
        shape: _pill,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }

  static OutlinedButtonThemeData outlinedButton(AppColors c) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.text,
        backgroundColor: c.glassFill,
        side: BorderSide(color: c.glassBorder),
        minimumSize: const Size(0, AppLayout.primaryButtonMinHeight),
        shape: _pill,
      ),
    );
  }

  static InputDecorationTheme input(AppColors c) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: AppRadius.control,
      borderSide: BorderSide(color: color),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: c.glassFill,
      border: border(c.glassBorder),
      enabledBorder: border(c.glassBorder),
      focusedBorder: border(c.accent),
      hintStyle: TextStyle(color: c.text3),
    );
  }

  static SnackBarThemeData snackBar(AppColors c) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.surfaceSolid,
      contentTextStyle: TextStyle(color: c.text, fontWeight: FontWeight.w600),
      shape: _pill,
    );
  }

  static BottomSheetThemeData bottomSheet(AppColors c) {
    return BottomSheetThemeData(
      backgroundColor: c.bg,
      modalBackgroundColor: c.bg,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
    );
  }

  static DialogThemeData dialog(AppColors c) {
    return DialogThemeData(
      backgroundColor: c.surfaceSolid,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
    );
  }

  static SwitchThemeData switchTheme(AppColors c) {
    return SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? c.accent
            : c.lineStrong,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }
}
