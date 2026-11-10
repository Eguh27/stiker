# Fase 5 — Frontend
Target: Canvas Editor interaktif (CustomPainter, multi-touch, undo/redo, layer panel) dan Text Editor dengan font & preset manifest.
Kontrak terkait: docs/contracts/project-schema.md, docs/contracts/manifests.md
Desain terkait: design/screen-map.md (imageEditor, textEditor), App.tsx `ImageEditor` & `TextEditor`
Depends on: F4-INT-01

## [F5-FE-01] Canvas Editor & Scene Graph
Status: DONE
Owner: FE
Depends on: F4-INT-01

### Konteks
Layar utama editor stiker (App.tsx `ImageEditor`): TopBar (Edit stiker, Selesai), action bar (undo, redo, layers), canvas grid interaktif dengan CustomPainter, gesture drag/scale/rotate, panel layer, dan bottom toolbar (Teks, Kuas, Hapus BG, Border, Stiker).

### Input
- design/screen-map.md (imageEditor)
- design/tokens.json
- docs/contracts/project-schema.md

### Output
- lib/features/editor/presentation/image_editor_page.dart
- lib/features/editor/presentation/editor_canvas.dart (CustomPainter)
- lib/features/editor/presentation/editor_action_bar.dart (undo, redo, layers toggle)
- lib/features/editor/presentation/editor_layer_panel.dart
- lib/features/editor/presentation/editor_toolbar.dart
- lib/features/editor/domain/scene_graph.dart (Layer, ImageLayer, TextLayer, Transform)
- lib/features/editor/domain/editor_history.dart (Undo/Redo command stack)
- lib/features/editor/presentation/editor_providers.dart
- test/features/editor/image_editor_test.dart

### Acceptance Criteria
- [ ] TopBar dengan tombol Selesai dan Back
- [ ] Canvas menampilkan stiker dan teks dengan posisi/transformasi
- [ ] Gesture pan/scale/rotate dapat memanipulasi layer aktif
- [ ] Undo dan Redo berfungsi membatalkan dan mengulang perubahan state
- [ ] Layer panel dapat dibuka/tutup, menampilkan daftar layer
- [ ] Toolbar menampilkan 5 tools (Teks, Kuas, Hapus BG, Border, Stiker)
- [ ] Tanpa warna/spasi hardcode di luar tema

### Verification
```bash
flutter analyze
flutter test test/features/editor/image_editor_test.dart
```

## [F5-FE-02] Text Editor & Presets
Status: DONE
Owner: FE
Depends on: F5-FE-01

### Konteks
Layar penyunting teks stiker (App.tsx `TextEditor`): pratinjau teks real-time, input field teks (maks 40 karakter + counter), font selector (dari fonts_manifest), preset gaya (dari presets_manifest: Outline, Shadow, Latar), dan palette warna.

### Input
- design/screen-map.md (textEditor)
- design/tokens.json
- lib/features/data/registry/fonts_manifest.dart
- lib/features/data/registry/presets_manifest.dart

### Output
- lib/features/editor/presentation/text_editor_page.dart
- lib/features/editor/presentation/text_control_drawer.dart
- lib/features/editor/presentation/font_selector_row.dart
- lib/features/editor/presentation/style_preset_row.dart
- lib/features/editor/presentation/color_palette_row.dart
- test/features/editor/text_editor_test.dart

### Acceptance Criteria
- [ ] Input teks dengan counter batas 40 karakter
- [ ] Pilihan font terhubung ke daftar font manifest
- [ ] Pilihan preset gaya (Outline, Shadow, Latar) terhubung ke preset manifest
- [ ] Palette warna interaktif dengan indikator check
- [ ] Tombol Terapkan mengembalikan layer teks ke canvas editor

### Verification
```bash
flutter analyze
flutter test test/features/editor/text_editor_test.dart
```
