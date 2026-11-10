import '../../editor/domain/scene_project.dart';

/// Antarmuka penyimpanan dan pemuatan project kanvas stiker (tabel `projects`).
abstract class ProjectRepository {
  Future<void> saveProject(String stickerId, SceneProject project);
  Future<SceneProject?> loadProject(String stickerId);
  Future<void> deleteProject(String stickerId);
  Future<bool> hasProject(String stickerId);
}
