/// Profil & status lokal (Settings, screen-map F8). Domain murni.
class SettingsProfile {
  const SettingsProfile({
    required this.appName,
    required this.tagline,
    required this.version,
    required this.storageUsed,
    required this.storageTotal,
  });

  final String appName;
  final String tagline;
  final String version;
  final String storageUsed;
  final String storageTotal;
}
