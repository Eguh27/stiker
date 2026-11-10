import 'package:drift/drift.dart';
import 'package:sticker_studio/features/data/app_database.dart';
import 'package:sticker_studio/features/data/database/database_enums.dart';
import 'package:sticker_studio/features/data/import/import_id.dart';
import 'package:sticker_studio/features/editor/domain/scene_project.dart';

import 'project_json_codec.dart';
import 'project_repository.dart';

/// Implementasi SQLite Drift untuk menyimpan project stiker (tabel `projects`).
class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(
    this._database, {
    String Function()? createId,
    DateTime Function()? now,
  }) : _createId = createId ?? createImportId,
       _now = now ?? DateTime.now;

  final AppDatabase _database;
  final String Function() _createId;
  final DateTime Function() _now;

  @override
  Future<void> saveProject(String stickerId, SceneProject project) async {
    final String jsonStr = ProjectJsonCodec.encode(project);
    final DateTime now = _now();

    final stickerExists =
        await (_database.selectOnly(_database.stickers)
              ..addColumns([_database.stickers.id])
              ..where(_database.stickers.id.equals(stickerId)))
            .getSingleOrNull();

    if (stickerExists == null) {
      await _database
          .into(_database.stickers)
          .insert(
            StickersCompanion.insert(
              id: stickerId,
              filePath: '/app_data/stickers/$stickerId.webp',
              thumbPath: '/app_data/stickers/$stickerId.webp',
              width: 512,
              height: 512,
              sizeKb: 50,
              sha256: 'project-$stickerId',
              sourceType: SourceType.manualFile,
              createdAt: now,
            ),
          );
    }

    final existing = await (_database.select(
      _database.projects,
    )..where((t) => t.stickerId.equals(stickerId))).getSingleOrNull();

    if (existing == null) {
      await _database
          .into(_database.projects)
          .insert(
            ProjectsCompanion.insert(
              id: _createId(),
              stickerId: stickerId,
              projectJson: jsonStr,
              updatedAt: now,
            ),
          );
    } else {
      await (_database.update(
        _database.projects,
      )..where((t) => t.id.equals(existing.id))).write(
        ProjectsCompanion(projectJson: Value(jsonStr), updatedAt: Value(now)),
      );
    }
  }

  @override
  Future<SceneProject?> loadProject(String stickerId) async {
    final row = await (_database.select(
      _database.projects,
    )..where((t) => t.stickerId.equals(stickerId))).getSingleOrNull();
    if (row == null) return null;
    return ProjectJsonCodec.decode(row.projectJson);
  }

  @override
  Future<void> deleteProject(String stickerId) async {
    await (_database.delete(
      _database.projects,
    )..where((t) => t.stickerId.equals(stickerId))).go();
  }

  @override
  Future<bool> hasProject(String stickerId) async {
    final row =
        await (_database.selectOnly(_database.projects)
              ..addColumns([_database.projects.id])
              ..where(_database.projects.stickerId.equals(stickerId)))
            .getSingleOrNull();
    return row != null;
  }
}
