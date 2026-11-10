import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/settings/app_settings_dao.dart';

import 'support/test_database.dart';

void main() {
  test('getBool memakai nilai default saat key belum ada', () async {
    final AppDatabase database = createTestDatabase();
    addTearDown(database.close);

    final AppSettingsDao dao = AppSettingsDao(database);

    expect(await dao.getBool('auto_rmbg'), isFalse);
    expect(await dao.getBool('auto_rmbg', defaultValue: true), isTrue);
  });

  test('setBool menulis ulang nilai dan updated_at', () async {
    final AppDatabase database = createTestDatabase();
    addTearDown(database.close);
    final AppSettingsDao dao = AppSettingsDao(
      database,
      now: () => DateTime.utc(2026, 11, 10),
    );

    await dao.setBool(autoRmbgSettingKey, true);
    expect(await dao.getBool(autoRmbgSettingKey), isTrue);

    await dao.setBool(autoRmbgSettingKey, false);
    final AppSetting setting = await database
        .select(database.appSettings)
        .getSingle();
    expect(await dao.getBool(autoRmbgSettingKey), isFalse);
    expect(setting.updatedAt.toUtc(), DateTime.utc(2026, 11, 10));
  });

  test(
    'auto_rmbg bertahan setelah database ditutup dan dibuka ulang',
    () async {
      final Directory directory = await Directory.systemTemp.createTemp(
        'sticker_studio_settings_',
      );
      addTearDown(() => directory.delete(recursive: true));
      final File file = File(p.join(directory.path, 'app.sqlite'));

      final AppDatabase first = AppDatabase(openAppDatabase(file));
      await AppSettingsDao(first).setBool(autoRmbgSettingKey, true);
      await first.close();

      final AppDatabase second = AppDatabase(openAppDatabase(file));
      addTearDown(second.close);

      expect(await AppSettingsDao(second).getBool(autoRmbgSettingKey), isTrue);
    },
  );
}
