import 'settings_profile.dart';

/// Interface setelan; tema gelap disimpan sebagai state (mock).
abstract class SettingsRepository {
  Future<SettingsProfile> fetchProfile();
}
