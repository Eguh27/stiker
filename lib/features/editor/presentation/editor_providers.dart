import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_studio/features/data/project/project_providers.dart';
import 'package:sticker_studio/features/data/project/project_repository.dart';
import 'package:sticker_studio/features/queue/data/app_database_provider.dart';

import '../domain/editor_history.dart';
import '../domain/scene_layer.dart';
import '../domain/scene_project.dart';
import 'editor_state.dart';

final editorProvider =
    NotifierProvider.family<EditorNotifier, EditorState, String>(
      EditorNotifier.new,
    );

class EditorNotifier extends Notifier<EditorState> {
  EditorNotifier(this._stickerId);

  final String _stickerId;
  final EditorHistory _history = EditorHistory();

  @override
  EditorState build() {
    final initial = SceneProject(
      layers: [
        ImageLayer(
          id: 'sticker-base',
          imagePath: '/app_data/stickers/$_stickerId.webp',
          stickerId: _stickerId,
          transform: const LayerTransform(x: 256, y: 256, scale: 1.0),
        ),
      ],
    );
    Future<void>.microtask(_load);
    return EditorState(project: initial, activeLayerId: 'sticker-base');
  }

  Future<void> _load() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final stickerRow = await (db.select(
        db.stickers,
      )..where((t) => t.id.equals(_stickerId))).getSingleOrNull();

      final repo = ref.read(projectRepositoryProvider);
      final loaded = await repo.loadProject(_stickerId);
      if (loaded != null && loaded.layers.isNotEmpty) {
        state = state.copyWith(
          project: loaded,
          activeLayerId: () => loaded.layers.last.id,
        );
      } else if (stickerRow != null && stickerRow.filePath.isNotEmpty) {
        final initial = SceneProject(
          layers: [
            ImageLayer(
              id: 'sticker-base',
              imagePath: stickerRow.filePath,
              stickerId: _stickerId,
              transform: const LayerTransform(x: 256, y: 256, scale: 1.0),
            ),
          ],
        );
        state = state.copyWith(
          project: initial,
          activeLayerId: () => 'sticker-base',
        );
      }
    } on Object {
      // fallback ke initial project
    }
  }

  void setInitialImagePath(String path) {
    final updatedLayers = [
      for (final l in state.project.layers)
        if (l.id == 'sticker-base' && l is ImageLayer)
          ImageLayer(
            id: l.id,
            imagePath: path,
            stickerId: _stickerId,
            transform: l.transform,
          )
        else
          l,
    ];
    state = state.copyWith(
      project: state.project.copyWith(layers: updatedLayers),
    );
  }

  void selectLayer(String? id) {
    state = state.copyWith(activeLayerId: () => id);
  }

  void toggleLayersPanel() {
    state = state.copyWith(isLayersOpen: !state.isLayersOpen);
  }

  void _recordAndApply(SceneProject next) {
    _history.record(state.project);
    state = state.copyWith(
      project: next,
      canUndo: _history.canUndo,
      canRedo: _history.canRedo,
    );
  }

  void addLayer(SceneLayer layer) {
    final nextLayers = [...state.project.layers, layer];
    _recordAndApply(state.project.copyWith(layers: nextLayers));
    selectLayer(layer.id);
  }

  void updateTransform(String id, LayerTransform transform) {
    final nextLayers = [
      for (final l in state.project.layers)
        if (l.id == id) l.copyWithTransform(transform) else l,
    ];
    _recordAndApply(state.project.copyWith(layers: nextLayers));
  }

  void removeLayer(String id) {
    final nextLayers = state.project.layers.where((l) => l.id != id).toList();
    _recordAndApply(state.project.copyWith(layers: nextLayers));
    if (state.activeLayerId == id) {
      selectLayer(nextLayers.lastOrNull?.id);
    }
  }

  void toggleVisibility(String id) {
    final nextLayers = [
      for (final l in state.project.layers)
        if (l.id == id) l.copyWithVisibility(!l.visible) else l,
    ];
    _recordAndApply(state.project.copyWith(layers: nextLayers));
  }

  void undo() {
    final previous = _history.undo(state.project);
    if (previous != null) {
      state = state.copyWith(
        project: previous,
        canUndo: _history.canUndo,
        canRedo: _history.canRedo,
      );
    }
  }

  void redo() {
    final next = _history.redo(state.project);
    if (next != null) {
      state = state.copyWith(
        project: next,
        canUndo: _history.canUndo,
        canRedo: _history.canRedo,
      );
    }
  }

  Future<bool> save() async {
    if (state.isSaving) return false;
    state = state.copyWith(isSaving: true);
    try {
      final ProjectRepository repo = ref.read(projectRepositoryProvider);
      await repo.saveProject(_stickerId, state.project);
      state = state.copyWith(isSaving: false);
      return true;
    } on Object {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }
}
