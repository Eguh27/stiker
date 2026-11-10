import 'manifest_exception.dart';

const int supportedManifestVersion = 1;

/// Typed, path-aware access to the decoded JSON of a registry manifest.
class ManifestJson {
  ManifestJson(this._root, {required this.source});

  final Map<String, dynamic> _root;
  final String source;

  int get version {
    final value = integer(_root['version'], 'version');
    if (value != supportedManifestVersion) {
      fail(
        'version',
        'unsupported version $value, expected $supportedManifestVersion',
      );
    }
    return value;
  }

  Map<String, dynamic> object(Object? value, String path) {
    if (value is! Map<String, dynamic>) {
      fail(path, 'must be a JSON object');
    }
    return value;
  }

  List<Object?> list(Object? value, String path) {
    if (value is! List) {
      fail(path, 'must be a JSON array');
    }
    return List<Object?>.from(value);
  }

  String string(Object? value, String path) {
    if (value is! String || value.trim().isEmpty) {
      fail(path, 'must be a non-empty string');
    }
    return value;
  }

  String? optionalString(Object? value, String path) =>
      value == null ? null : string(value, path);

  bool boolean(Object? value, String path) {
    if (value is! bool) {
      fail(path, 'must be a boolean');
    }
    return value;
  }

  int integer(Object? value, String path) {
    if (value is! int) {
      fail(path, 'must be an integer');
    }
    return value;
  }

  Never fail(String path, String message) =>
      throw ManifestException(source: source, message: '$path: $message');
}
