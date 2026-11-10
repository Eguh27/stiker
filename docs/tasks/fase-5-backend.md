# Fase 5 — Backend
Target: Repository project JSON (Drift table `projects`) dan rendering scene project ke encoder Rust WebP.
Kontrak terkait: docs/contracts/project-schema.md, docs/contracts/db-schema.md, docs/contracts/ffi.md
Depends on: F4-BE-03

## [F5-BE-01] Project Repository & Serializer
Status: DONE
Owner: BE
Depends on: F4-BE-03

### Konteks
Tabel `projects(id, sticker_id, project_json, updated_at)` sudah ada di skema Drift. Tugas ini membuat model serialisasi JSON sesuai kontrak `project-schema.md` serta DAO/repository untuk menyimpan dan memuat project.

### Input
- docs/contracts/project-schema.md
- docs/contracts/db-schema.md
- lib/features/data/database/tables/projects.dart

### Output
- lib/features/data/project/project_json_codec.dart
- lib/features/data/project/project_repository.dart
- lib/features/data/project/project_repository_impl.dart
- test/data/project/project_json_codec_test.dart
- test/data/project/project_repository_test.dart

### Acceptance Criteria
- [ ] Serialisasi dan deserialisasi JSON lossless sesuai kontrak v0.1.0
- [ ] Menyimpan dan memuat project ke/dari tabel Drift `projects`
- [ ] Menolak JSON yang tidak valid dengan pesan error jelas
- [ ] Menjaga constraint foreign key `sticker_id`

### Verification
```bash
flutter analyze
flutter test test/data/project
```

## [F5-BE-02] Project Scene Renderer
Status: DONE
Owner: BE
Depends on: F5-BE-01

### Konteks
Saat user menekan "Selesai" di editor, scene graph harus dirender ke file gambar 512×512 lalu di-encode menjadi stiker WebP melalui Rust `encode_whatsapp_webp`.

### Input
- lib/features/data/project/*
- docs/contracts/ffi.md

### Output
- lib/features/data/project/project_scene_renderer.dart
- test/data/project/project_scene_renderer_test.dart

### Acceptance Criteria
- [ ] Merender layer stiker + teks ke kanvas 512×512
- [ ] Menghasilkan file WebP < 100 KB melalui Rust encoder
- [ ] Mengembalikan path file hasil render yang valid

### Verification
```bash
flutter analyze
flutter test test/data/project
```
