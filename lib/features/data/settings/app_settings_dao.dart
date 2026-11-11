import 'package:sticker_studio/features/data/app_database.dart';

/// Key setting global Auto-RMBG (db-schema.md v0.2.0).
const String autoRmbgSettingKey = 'auto_rmbg';

class AppSettingsDao {
  AppSettingsDao(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final AppSetting? setting = await (_database.select(
      _database.appSettings,
    )..where((row) => row.key.equals(key))).getSingleOrNull();
    if (setting == null) return defaultValue;
    return setting.value == '1';
  }

  Future<void> setBool(String key, bool value) async {
    await _database
        .into(_database.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            value: value ? '1' : '0',
            updatedAt: _now(),
          ),
        );
  }

  Future<String?> getString(String key) async {
    final AppSetting? setting = await (_database.select(
      _database.appSettings,
    )..where((row) => row.key.equals(key))).getSingleOrNull();
    return setting?.value;
  }

  Future<void> setString(String key, String value) async {
    await _database
        .into(_database.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: key, value: value, updatedAt: _now()),
        );
  }
}
