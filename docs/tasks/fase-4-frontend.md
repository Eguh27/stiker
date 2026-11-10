# Fase 4 — Frontend
Target: UI Pack Editor (tray icon, drag-and-drop, emoji, validasi 3-30) dengan mock dulu.
Kontrak terkait: docs/contracts/db-schema.md, design/screen-map.md
Desain terkait: design/screen-map.md (packs, packEditor), App.tsx `PackEditor`
Depends on: F3-FE-01

## [F4-FE-01] Pack Editor
Status: DONE
Owner: FE
Depends on: F3-FE-01

### Konteks
Pack list sudah ada dengan mock. Sekarang layar buat/edit pack sesuai desain `PackEditor`: header tray, field nama/pembuat, grid susun stiker, emoji maks 3, validasi, tombol WhatsApp.

### Input
- design/screen-map.md, design/tokens.json
- lib/core/widgets/*, lib/features/packs/presentation/packs_page.dart
- docs/contracts/db-schema.md (bentuk data saja)

### Output
- lib/features/packs/presentation/pack_editor_page.dart
- lib/features/packs/presentation/{pack_header_card,pack_edit_grid,emoji_picker,validation_card}.dart
- lib/features/packs/domain/*: perluas interface `PackRepository` (create/update/reorder) + fake
- test/features/packs/pack_editor_test.dart

### Acceptance Criteria
- [x] Tray icon 96×96 dengan badge edit; nama/pembuat maks 28 + counter
- [x] Grid susun stiker + tombol Tambah; drag-and-drop reorder
- [x] Emoji maks 3 (ke-4 ditekan tidak menambah)
- [x] Validasi 3–30 tampil hijau/merah; WhatsApp button disabled <3
- [x] loading/empty/error; tanpa hardcode warna/ukuran di luar tema
- [x] Hanya `lib/**/presentation` + `lib/core` + `lib/**/domain` (interface/fake)

### Verification
```bash
flutter analyze
flutter test test/features/packs
```

### Catatan
- **PM finding (2026-11-10):** suite penuh menyisakan **1 test hang**, bukan 9 (angka 9 sebelumnya berasal dari run paralel yang saling mengganggu). Test: `test/features/packs/pack_editor_flow_test.dart` → "Simpan pack sunting memakai update + reorder" berakhir `did not complete`.
- **Root cause:** test meng-`await fake.fetchPackDetail('p1')` (line 107) padahal `FakePackRepository` memakai `Future.delayed(100ms)` di fake-time. Tanpa `tester.pump(Duration)`/`runAsync`, future itu tidak pernah selesai → test menggantung. Kode produksi tidak terbukti salah.
- **Perbaikan yang diminta:** bungkus pemanggilan itu dengan `tester.runAsync(...)` atau sediakan getter sinkron di fake untuk test. Jangan mengubah delay fake atau menghapus test.
- Skill: flutter-expert + clean-code + test-master.
- Jangan sentuh `lib/**/data`, `rust/`, `android/`.
- Jangan ubah signature `PackRepository` yang sudah dipakai `packs_page` tanpa lapor PM.
