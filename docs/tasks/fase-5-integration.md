# Fase 5 — Integrasi
Target: Hubungkan UI Image & Text Editor ke Project Repository dan Scene Renderer.
Kontrak terkait: docs/contracts/project-schema.md
Depends on: F5-FE-01, F5-FE-02, F5-BE-01, F5-BE-02

## [F5-INT-01] Wiring Editor & Project Store
Status: DONE
Owner: FE (implementasi) + BE (review)
Depends on: F5-FE-01, F5-FE-02, F5-BE-01, F5-BE-02

### Konteks
Menghubungkan `ImageEditorPage` dengan `ProjectRepository` sehingga saat membuka stiker, project dimuat, dan saat menekan "Selesai", project disimpan dan stiker dirender.

### Output
- `editorProjectProvider` terhubung ke `ProjectRepository`
- Navigasi dari Sticker Library & Pack Editor menuju `ImageEditorPage` dan `TextEditorPage`
- test/features/editor/editor_integration_test.dart

### Acceptance Criteria
- [ ] Buka stiker dari library/pack membuka canvas dengan layer stiker tersebut
- [ ] Tambah teks dari TextEditor masuk sebagai layer baru di canvas
- [ ] Tekan Selesai menyimpan project JSON ke DB
- [ ] Semua test editor dan project lulus

### Verification
```bash
flutter analyze
flutter test test/features/editor test/data/project
```
