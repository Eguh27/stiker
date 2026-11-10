import 'manifest_json.dart';

final RegExp _hostPattern = RegExp(r'^[a-z0-9-]+(\.[a-z0-9-]+)*$');

class ExtractorsManifest {
  const ExtractorsManifest({required this.version, required this.extractors});

  factory ExtractorsManifest.fromJson(
    Map<String, dynamic> json, {
    required String source,
  }) {
    final reader = ManifestJson(json, source: source);
    final version = reader.version;
    final entries = reader.list(json['extractors'], 'extractors');
    final extractors = <ExtractorRule>[];

    for (final (index, entry) in entries.indexed) {
      final path = 'extractors[$index]';
      final map = reader.object(entry, path);
      final domains = reader
          .list(map['domain'], '$path.domain')
          .map(
            (value) => _normalizeDomain(
              reader,
              '$path.domain',
              reader.string(value, '$path.domain'),
            ),
          )
          .toList(growable: false);

      if (domains.isEmpty) {
        reader.fail('$path.domain', 'must contain at least one domain');
      }

      extractors.add(
        ExtractorRule(
          domains: List.unmodifiable(domains),
          strategy: reader.string(map['strategy'], '$path.strategy'),
          needsLogin: reader.boolean(map['needs_login'], '$path.needs_login'),
        ),
      );
    }

    return ExtractorsManifest(
      version: version,
      extractors: List.unmodifiable(extractors),
    );
  }

  final int version;
  final List<ExtractorRule> extractors;

  ExtractorRule? ruleFor(Uri uri) {
    final host = uri.host.toLowerCase();
    if (host.isEmpty) {
      return null;
    }
    for (final rule in extractors) {
      if (rule.matchesHost(host)) {
        return rule;
      }
    }
    return null;
  }
}

class ExtractorRule {
  const ExtractorRule({
    required this.domains,
    required this.strategy,
    required this.needsLogin,
  });

  final List<String> domains;
  final String strategy;
  final bool needsLogin;

  bool matchesHost(String host) {
    final normalizedHost = host.toLowerCase();
    return domains.any(
      (domain) =>
          normalizedHost == domain || normalizedHost.endsWith('.$domain'),
    );
  }
}

String _normalizeDomain(ManifestJson reader, String path, String value) {
  final domain = value.trim().toLowerCase();
  if (!_hostPattern.hasMatch(domain)) {
    reader.fail(path, 'invalid domain "$value"');
  }
  return domain;
}
