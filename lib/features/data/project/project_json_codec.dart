import 'dart:convert';

import '../../editor/domain/scene_project.dart';

class ProjectCodecException implements Exception {
  const ProjectCodecException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Serialisasi dan deserialisasi JSON untuk project kanvas stiker.
class ProjectJsonCodec {
  const ProjectJsonCodec._();

  static String encode(SceneProject project) {
    return jsonEncode(project.toJson());
  }

  static SceneProject decode(String raw) {
    if (raw.trim().isEmpty) {
      throw const ProjectCodecException('Project JSON tidak boleh kosong.');
    }
    try {
      final Object? parsed = jsonDecode(raw);
      if (parsed is! Map<String, dynamic>) {
        throw const ProjectCodecException(
          'Root project JSON harus berupa objek.',
        );
      }
      if (!parsed.containsKey('version')) {
        throw const ProjectCodecException(
          'Project JSON wajib memiliki field version.',
        );
      }
      return SceneProject.fromJson(parsed);
    } on FormatException catch (e) {
      throw ProjectCodecException('Format JSON tidak valid: ${e.message}');
    }
  }
}
