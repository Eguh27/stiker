# Fase 4 — Backend
Target: Migrasi `app_settings` (kontrak v0.2.0) + repository pack dengan validasi WhatsApp.
Kontrak terkait: docs/contracts/db-schema.md v0.2.0
Desain terkait: -
Depends on: F3-BE-03

## [F4-BE-00] Review deviasi kepemilikan FE di queue/data
Status: DONE
Owner: BE
Depends on: F3-FE-01

### Konteks
FE menulis `lib/features/queue/data/app_database_provider.dart` dan `drift_queue_repository.dart` — area milik BE. Kode sudah dites dan dipakai; tugas ini memverifikasi kualitasnya tanpa mengubah perilaku.

### Input
- lib/features/queue/data/*.dart, test/features/queue/drift_queue_test.dart

### Output
- Laporan review; perbaikan hanya jika ada bug/penyimpangan kontrak

### Acceptance Criteria
- [x] Mapping `SourceType`/`ImportStatus` sesuai kontrak db-schema
- [x] Retry reset `status=pending, progress=0, error_message=null`
- [x] Tidak ada query yang melanggar batas 20/50 MB atau enum
- [x] Ditambahkan test regresi bila ditemukan celah

### Hasil
- Tidak ada bug produksi. Ditambah `test/features/queue/drift_queue_mapping_test.dart` (semua enum) + perluasan `drift_queue_test.dart` (retry hapus error, persistensi Auto-RMBG).

### Verification
```bash
flutter analyze
flutter test test/features/queue
```

## [F4-BE-01] Migrasi `app_settings` (DB v2)
Status: DONE
Owner: BE
Depends on: F4-BE-00

### Konteks
Auto-RMBG global F3-FE-01 masih in-memory. Kontrak 0.2.0 menambah tabel `app_settings(key, value, updated_at)` agar persist.

### Input
- docs/contracts/db-schema.md v0.2.0, lib/features/data/app_database.dart

### Output
- `app_settings` table + DAO (`getBool/setBool`)
- migrasi schema v1 -> v2 + `drift_schemas` v2 + test migrasi

### Acceptance Criteria
- [x] Tabel dan migrasi sesuai kontrak v0.2.0
- [x] Migration test v1 -> v2 lulus (data lama utuh)
- [x] `auto_rmbg` tersimpan lintas restart DB
- [x] Tidak mengubah tabel lain

### Hasil
- `drift_schemas/drift_schema_v2.json`, `app_settings_dao` (boolean '1'/'0'), `AutoRmbg` default true lewat DAO.
- Verifikasi PM: `flutter test test/data` -> 91 passed (independen).

### Verification
```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/data
```

## [F4-BE-02] Repository pack + validasi WhatsApp
Status: DONE
Owner: BE
Depends on: F4-BE-01

### Konteks
Pack CRUD nyata dibutuhkan UI Pack Editor (F4-FE-01). Aturan WA: 3–30 stiker, nama/pembuat maks 28 karakter, tray icon 96×96, `version` auto-increment.

### Input
- docs/contracts/db-schema.md, docs/contracts/manifests.md

### Output
- lib/features/data/pack/pack_repository_impl.dart (Drift pack + pack_stickers)
- validasi: nama/pembuat <= 28, 3..30 stiker, urutan `position` unik
- `version` auto-increment saat `is_synced` berubah / isi berubah

### Acceptance Criteria
- [x] CRUD pack + reorder stiker (position) konsisten
- [x] Validasi menolak <3 atau >30 stiker dengan error jelas
- [x] `version` naik tepat sekali per perubahan konten
- [x] Tidak menyentuh `lib/**/presentation`

### Verification
```bash
flutter analyze
flutter test test/data/pack
```

### Hasil
- `pack_repository_impl`, `pack_editor`, `pack_lifecycle`, `pack_store`, `pack_validation`, `pack_details`, `pack_version`, `sticker_order` + 14 test.
- `version` tidak naik pada no-op/reorder identik.
- Tray icon 96×96/<50 KB ditunda ke encoder/FFI (repo hanya wajib path).
- Gap: API `PackRepositoryImpl` lebih kaya dari `PackEditorRepository` FE -> adapter di F4-INT-01.

### Catatan
- Skill: sql-pro + clean-code + test-master. Context7 untuk Drift sebelum migrasi.
- Jangan sentuh `rust/`, `android/`, `lib/**/presentation`.

## [F4-BE-03] Migrasi `packs.emojis` (DB v3)
Status: DONE
Owner: BE
Depends on: F4-BE-02

### Konteks
Tag emoji (maks 3) wajib untuk metadata pack WhatsApp, tapi saat ini hanya draft FE dan hilang saat reload. Kontrak v0.3.0 menambah kolom `packs.emojis`.

### Input
- docs/contracts/db-schema.md v0.3.0, lib/features/data/pack/*

### Output
- kolom `emojis` + serialisasi JSON array + validasi maks 3 & nilai dari daftar `PackLimits.emojiTagOptions`
- migrasi v2 -> v3 + `drift_schemas/drift_schema_v3.json` + test migrasi
- `pack_repository_impl` menyimpan/mengembalikan emoji

### Acceptance Criteria
- [x] Migrasi v2 -> v3 lulus, data pack lama utuh (default `[]`)
- [x] Simpan 0..3 emoji; >3 ditolak dengan error jelas
- [x] Emoji terbaca ulang setelah restart DB
- [x] Test repo pack + migrasi hijau

### Verification
```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test test/data
```
