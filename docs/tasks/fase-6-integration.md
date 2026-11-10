# Fase 6 — Integrasi
Target: Hubungkan UI Remove Background dan Border Editor ke Image Editor & FFI/State.
Kontrak terkait: docs/contracts/ffi.md
Depends on: F6-FE-01, F6-FE-02, F6-BE-01, F6-BE-02

## [F6-INT-01] Wiring RMBG & Border ke Editor Shell
Status: DONE
Owner: FE + BE
Depends on: F6-FE-01, F6-FE-02, F6-BE-01, F6-BE-02

### Konteks
Menghubungkan toolbar `Hapus BG` dan `Border` di `ImageEditorPage` ke `RemoveBackgroundPage` dan `BorderEditorPage`. Hasil perubahan border atau masking diperbarui ke layer stiker di canvas editor.

### Output
- Navigasi dan parameter passing di `ImageEditorPage`
- test/features/editor/rmbg_border_flow_test.dart

### Acceptance Criteria
- [ ] Tombol Hapus BG membuka RemoveBackgroundPage dan mengembalikan hasil mask
- [ ] Tombol Border membuka BorderEditorPage dan memperbarui style border layer aktif
- [ ] Semua test lulus di `flutter analyze` dan `flutter test`

### Verification
```bash
flutter analyze
flutter test
cargo test --manifest-path rust/Cargo.toml
```
