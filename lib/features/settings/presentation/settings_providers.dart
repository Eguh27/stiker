import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/settings/app_settings_dao.dart';
import '../../queue/data/app_database_provider.dart';
import '../domain/fake_settings_repository.dart';
import '../domain/settings_profile.dart';
import '../domain/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return FakeSettingsRepository();
});

final settingsProfileProvider = FutureProvider<SettingsProfile>((ref) async {
  final SettingsRepository repository = ref.watch(settingsRepositoryProvider);
  return repository.fetchProfile();
});

/// Mode tema tersimpan di app_settings agar bertahan setelah app ditutup.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _settingKey = 'theme_mode';

  @override
  ThemeMode build() {
    _restore();
    return ThemeMode.system;
  }

  void setDark(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    _persist(state);
  }

  Future<void> _restore() async {
    try {
      final saved = await _settings().getString(_settingKey);
      final mode = ThemeMode.values.asNameMap()[saved];
      if (mode != null) state = mode;
    } catch (_) {
      // Database belum siap: tetap pakai tema sistem.
    }
  }

  Future<void> _persist(ThemeMode mode) async {
    try {
      await _settings().setString(_settingKey, mode.name);
    } catch (_) {
      // Gagal menyimpan tidak boleh mengganggu pergantian tema.
    }
  }

  AppSettingsDao _settings() => AppSettingsDao(ref.read(appDatabaseProvider));
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
