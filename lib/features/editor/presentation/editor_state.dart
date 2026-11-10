import '../domain/scene_layer.dart';
import '../domain/scene_project.dart';

/// State layar ImageEditor.
class EditorState {
  const EditorState({
    required this.project,
    this.activeLayerId,
    this.isLayersOpen = false,
    this.isSaving = false,
    this.zoom = 1.0,
    this.canUndo = false,
    this.canRedo = false,
  });

  final SceneProject project;
  final String? activeLayerId;
  final bool isLayersOpen;
  final bool isSaving;
  final double zoom;
  final bool canUndo;
  final bool canRedo;

  SceneLayer? get activeLayer {
    final id = activeLayerId;
    if (id == null) return project.layers.lastOrNull;
    return project.layers.where((l) => l.id == id).firstOrNull ??
        project.layers.lastOrNull;
  }

  EditorState copyWith({
    SceneProject? project,
    String? Function()? activeLayerId,
    bool? isLayersOpen,
    bool? isSaving,
    double? zoom,
    bool? canUndo,
    bool? canRedo,
  }) {
    return EditorState(
      project: project ?? this.project,
      activeLayerId: activeLayerId != null
          ? activeLayerId()
          : this.activeLayerId,
      isLayersOpen: isLayersOpen ?? this.isLayersOpen,
      isSaving: isSaving ?? this.isSaving,
      zoom: zoom ?? this.zoom,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
    );
  }
}
