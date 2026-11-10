class ManifestException implements Exception {
  const ManifestException({required this.source, required this.message});

  final String source;
  final String message;

  @override
  String toString() => 'ManifestException($source): $message';
}
