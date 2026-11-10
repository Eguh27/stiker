# Fase 1 — Backend
Target: Rail DB + FFI + File System + Registry berjalan dengan test hijau.
Kontrak terkait: docs/contracts/ffi.md, db-schema.md, manifests.md, stack.md
Depends on: F0-PM-01

## [F1-BE-01] Skema Drift + migrasi
Status: DONE
Owner: BE
Depends on: F0-PM-01

### Konteks
Kontrak DB harus jadi kode sebelum Queue Watcher/Repository bisa ditulis.

### Input
- docs/contracts/db-schema.md

### Output
- lib/features/data/app_database.dart (5 tabel, WAL, busy_timeout 5000)
- migrasi + test

### Acceptance Criteria
- [x] 5 tabel sesuai kontrak (packs, stickers, pack_stickers, import_queue, projects)
- [x] WAL aktif; `source_type` dan `status` tervalidasi sesuai enum
- [x] Migration test lulus

### Verification
```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/data
```

## [F1-BE-02] File System Manager (app_data/)
Status: DONE
Owner: BE
Depends on: F1-BE-01

### Konteks
Semua file lewat `app_data/` (originals/, stickers/, registry/) agar Kotlin `content://` bisa disalin saat izin URI sementara.

### Input
- docs/contracts/db-schema.md, docs/contracts/manifests.md

### Output
- lib/features/data/file_system_manager.dart (init + path helpers)

### Acceptance Criteria
- [x] Folder `app_data/originals`, `stickers`, `registry` dibuat di first-run
- [x] Helper path lolos unit test; error berupa Exception, bukan crash diam-diam

### Verification
```bash
flutter analyze
flutter test test/data/file_system_manager_test.dart
```

## [F1-BE-03] Registry Engine (baca manifest JSON)
Status: DONE
Owner: BE
Depends on: F0-PM-01

### Konteks
Parser manifest untuk extractors/presets/fonts/themes. Pinterest tidak boleh di-hardcode.

### Input
- docs/contracts/manifests.md

### Output
- lib/features/data/registry_engine.dart + model manifest
- rust tidak diubah di task ini kecuali perlu parser berbagi (ajukan ke PM dulu)

### Acceptance Criteria
- [x] Manifest valid diparse; manifest rusak mengembalikan error yang jelas
- [x] Unit test manifest valid + invalid

### Verification
```bash
flutter test test/data/registry_engine_test.dart
```

## [F1-BE-04] Rapikan flutter_rust_bridge (hapus greet)
Status: DONE (host-only, uji HP ditunda)
Owner: BE
Depends on: F0-PM-01

### Konteks
Ganti contoh quickstart `greet` dengan struktur API sesuai kontrak (minimal 1 stub typed).

### Input
- docs/contracts/ffi.md, rust/src/api/simple.rs, lib/main.dart

### Output
- rust/src/api/* disusun per domain (encode/border/rmbg/resolve) sesuai signature
- `flutter_rust_bridge` regen + build HP lolos

### Acceptance Criteria
- [x] `greet` dihapus; tidak ada `#[frb(sync)]` untuk fungsi berat
- [x] `cargo test`, clippy, fmt lulus; FFI path-based, bukan byte besar

### Verification
```bash
cargo fmt --check
cargo clippy --all-targets --all-features
cargo test
flutter run -d <hp fisik>   # konfirmasi bridge hidup di HP nyata
```

### Benchmark (Fase 1: belum wajib penuh, catat dasar)
- FFI round-trip kecil < 100 ms di HP; catat angka di laporan ke PM.

### Catatan / Blocker
- Skill: rust-engineer + sql-pro (skema) + clean-code + test-master. Cek Context7 untuk drift/flutter_rust_bridge v2.13 sebelum mengubah signature.
- Build Rust Android butuh Android SDK/NDK di mesin; jika `cargo test` gagal karena NDK, lapor BLOCKED dengan log, jangan fake pass.
- Jangan sentuh `lib/**/presentation`. Domain berubah hanya lewat PM.
