import 'scene_project.dart';

/// Riwayat undo/redo untuk manipulasi kanvas stiker.
class EditorHistory {
  EditorHistory({this.maxHistory = 30});

  final int maxHistory;
  final List<SceneProject> _undoStack = [];
  final List<SceneProject> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void record(SceneProject project) {
    _undoStack.add(project);
    if (_undoStack.length > maxHistory) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  SceneProject? undo(SceneProject current) {
    if (!canUndo) return null;
    _redoStack.add(current);
    return _undoStack.removeLast();
  }

  SceneProject? redo(SceneProject current) {
    if (!canRedo) return null;
    _undoStack.add(current);
    return _redoStack.removeLast();
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}
