import 'settings_profile.dart';
import 'settings_repository.dart';

/// Fake profil untuk shell mock & test.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({SettingsProfile? profile, this.errorToThrow})
    : profile = profile ?? FakeSettingsRepository.localProfile;

  FakeSettingsRepository.failing() : this(errorToThrow: StateError('offline'));

  final SettingsProfile profile;
  final Object? errorToThrow;

  static const SettingsProfile localProfile = SettingsProfile(
    appName: 'Sticker Studio',
    tagline: 'Ringan. Privat. Milikmu.',
    version: 'v1.4.0',
    storageUsed: '428 MB',
    storageTotal: '2 GB',
  );

  @override
  Future<SettingsProfile> fetchProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final Object? error = errorToThrow;
    if (error != null) throw error;
    return profile;
  }
}
