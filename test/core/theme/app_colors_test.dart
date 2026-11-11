import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';
import 'package:sticker_studio/core/theme/app_theme.dart';

void main() {
  group('AppColors - Warm Glassmorphism', () {
    test('accent oranye-merah menyala di kedua mode', () {
      expect(AppColors.light.accent, const Color(0xFFFF4500));
      expect(AppColors.dark.accent.a, 1);
      expect(AppColors.light.accentText, const Color(0xFFFFFFFF));
    });

    test('latar gradasi pastel (light) dan plum gelap (dark)', () {
      expect(AppColors.light.bgTop, const Color(0xFFFFFFFF));
      expect(AppColors.light.bgMid, const Color(0xFFFFD6E2));
      expect(AppColors.dark.bgTop, const Color(0xFF1C0F1A));
    });

    test('kaca semi-transparan dengan border tipis', () {
      expect(AppColors.light.glassFill.a, lessThan(1));
      expect(AppColors.dark.glassFill.a, lessThan(0.2));
      expect(AppColors.light.glassBorder.a, greaterThan(0));
    });

    test('palet stiker dipakai bersama', () {
      expect(AppColors.light.stickerLavender, const Color(0xFFCFC4F4));
      expect(AppColors.light.stickerPeach, const Color(0xFFEFBCA9));
      expect(AppColors.dark.stickerPink, const Color(0xFFE9BDCD));
    });
  });

  group('AppSpacing - tokens.json', () {
    test('spacing scale', () {
      expect(AppSpacing.s1, 4);
      expect(AppSpacing.s2, 8);
      expect(AppSpacing.s3, 12);
      expect(AppSpacing.s4, 16);
      expect(AppSpacing.s5, 20);
      expect(AppSpacing.s6, 24);
      expect(AppSpacing.s8, 32);
    });

    test('radius', () {
      expect(AppRadius.cardValue, 28);
      expect(AppRadius.controlValue, 20);
      expect(AppRadius.pillValue, 100);
    });

    test('layout matches index.css', () {
      expect(AppLayout.topBarHeight, 96);
      expect(AppLayout.bottomNavHeight, 88);
    });
  });

  group('AppTheme', () {
    test('light and dark have M3 and token colors', () {
      final ThemeData light = AppTheme.light;
      final ThemeData dark = AppTheme.dark;
      expect(light.useMaterial3, isTrue);
      expect(dark.useMaterial3, isTrue);
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(light.colorScheme.primary, AppColors.light.accent);
      expect(dark.colorScheme.primary, AppColors.dark.accent);
    });

    test('scaffold transparan agar GlassBackground terlihat', () {
      expect(AppTheme.light.scaffoldBackgroundColor, Colors.transparent);
      expect(AppTheme.dark.scaffoldBackgroundColor, Colors.transparent);
    });

    test('font Nunito dan sudut kapsul', () {
      expect(AppTheme.light.textTheme.titleLarge?.fontFamily, 'Nunito');
    });
  });
}
