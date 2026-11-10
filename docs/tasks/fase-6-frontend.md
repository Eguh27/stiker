# Fase 6 — Frontend
Target: UI Remove Background (brush erase/restore, feather, loupe magnifier) dan Border Editor (slider real-time, color picker, preview).
Kontrak terkait: docs/contracts/ffi.md
Desain terkait: design/screen-map.md (`removeBg`, `border`), App.tsx `RemoveBackground` & `BorderEditor`
Depends on: F5-INT-01

## [F6-FE-01] AppSlider & Remove Background UI
Status: DONE
Owner: FE
Depends on: F5-INT-01

### Konteks
Layar `RemoveBackgroundPage` memungkinkan pengguna menghapus latar belakang stiker secara manual menggunakan kuas (Erase / Restore), mengatur ukuran kuas dan feather, serta melihat pratinjau pembesar (loupe magnifier).

### Output
- `lib/core/widgets/app_slider.dart` (Reusable range control)
- `lib/features/editor/presentation/remove_background_page.dart`
- `lib/features/editor/presentation/checker_canvas.dart`
- `lib/features/editor/presentation/loupe_magnifier.dart`
- `test/features/editor/remove_background_test.dart`

### Acceptance Criteria
- [ ] TopBar "Hapus Background" dengan tombol Terapkan dan Back
- [ ] Mode toggle Erase dan Restore
- [ ] AppSlider untuk Ukuran kuas (0-100 px) dan Feather (0-100%)
- [ ] Loupe magnifier mengikuti atau menampilkan area aktif
- [ ] Navigasi dari ImageEditorPage (toolbar "Hapus BG")
- [ ] Zero theme hardcoding

### Verification
```bash
flutter analyze
flutter test test/features/editor/remove_background_test.dart
```

## [F6-FE-02] Border Editor UI & Real-Time Controls
Status: DONE
Owner: FE
Depends on: F6-FE-01

### Konteks
Layar `BorderEditorPage` memungkinkan pengguna menambahkan dan mengatur border stiker dengan slider ketebalan (width px) dan kelembutan (feather %), serta memilih warna border dari color row.

### Output
- `lib/features/editor/presentation/border_editor_page.dart`
- `lib/features/editor/presentation/border_preview_canvas.dart`
- `test/features/editor/border_editor_test.dart`

### Acceptance Criteria
- [ ] TopBar "Border Stiker" dengan tombol Terapkan dan Back
- [ ] Canvas preview menampilkan stiker dengan border stroke / drop-shadow
- [ ] AppSlider ketebalan (0-100 px) dan feather (0-100%)
- [ ] Pilihan 5 warna border dengan indikator centang
- [ ] Navigasi dari ImageEditorPage (toolbar "Border")
- [ ] Nilai border diterapkan kembali ke canvas stiker

### Verification
```bash
flutter analyze
flutter test test/features/editor/border_editor_test.dart
```
