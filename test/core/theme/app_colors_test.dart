import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_studio/core/theme/app_colors.dart';
import 'package:sticker_studio/core/theme/app_spacing.dart';
import 'package:sticker_studio/core/theme/app_theme.dart';

void main() {
  group('AppColors - tokens.json', () {
    test('light matches tokens', () {
      const AppColors colors = AppColors.light;
      expect(colors.canvas, const Color(0xFFE1DBD6));
      expect(colors.bg, const Color(0xFFF9F6F2));
      expect(colors.accent, const Color(0xFF7463B5));
      expect(colors.accentSoft, const Color(0xFFE8E1FF));
      expect(colors.surfaceSolid, const Color(0xFFFFFFFF));
      expect(colors.text, const Color(0xFF282522));
      expect(colors.text2, const Color(0xFF6E6862));
      expect(colors.text3, const Color(0xFF918A84));
      expect(colors.success, const Color(0xFF4F8066));
      expect(colors.danger, const Color(0xFFA65454));
      expect(colors.warning, const Color(0xFF9A743E));
      expect(colors.whatsapp, const Color(0xFF287D4F));
    });

    test('dark matches tokens', () {
      const AppColors colors = AppColors.dark;
      expect(colors.canvas, const Color(0xFF23211F));
      expect(colors.bg, const Color(0xFF1B1A19));
      expect(colors.accent, const Color(0xFFAA98ED));
      expect(colors.accentSoft, const Color(0xFF3F3859));
      expect(colors.surfaceSolid, const Color(0xFF302E2C));
      expect(colors.text, const Color(0xFFF5F1ED));
      expect(colors.text2, const Color(0xFFBCB5AF));
      expect(colors.text3, const Color(0xFF88817B));
      expect(colors.success, const Color(0xFF85BA9B));
      expect(colors.danger, const Color(0xFFE0928E));
      expect(colors.warning, const Color(0xFFD6AD70));
    });

    test('sticker palette shared', () {
      expect(AppColors.light.stickerLavender, const Color(0xFFCFC4F4));
      expect(AppColors.light.stickerPeach, const Color(0xFFEFBCA9));
      expect(AppColors.dark.stickerPink, const Color(0xFFE9BDCD));
    });

    test('surface has alpha from rgba', () {
      expect(AppColors.light.surface.a, closeTo(0.72, 0.02));
      expect(AppColors.dark.surface.a, closeTo(0.76, 0.02));
      expect(AppColors.light.line.a, closeTo(0.10, 0.02));
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
      expect(AppRadius.cardValue, 20);
      expect(AppRadius.controlValue, 14);
      expect(AppRadius.pillValue, 999);
    });

    test('layout matches index.css', () {
      expect(AppLayout.topBarHeight, 96);
      expect(AppLayout.bottomNavHeight, 80);
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

    test('scaffold uses token bg', () {
      expect(AppTheme.light.scaffoldBackgroundColor, AppColors.light.bg);
      expect(AppTheme.dark.scaffoldBackgroundColor, AppColors.dark.bg);
    });
  });
}
