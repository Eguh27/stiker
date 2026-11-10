String incrementPackVersion(String version) {
  final int current = int.tryParse(version) ?? 0;
  return '${current + 1}';
}
