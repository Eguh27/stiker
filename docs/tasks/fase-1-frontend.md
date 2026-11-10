# Fase 1 — Frontend
Target: Tema Flutter dari tokens.json + shell navigasi 4 tab dengan mock, siap uji di HP fisik.
Kontrak terkait: docs/contracts/stack.md, design/tokens.json, design/screen-map.md
Desain terkait: design/screen-map.md (BottomNav + TopBar)
Depends on: F0-PM-01

## [F1-FE-01] Tema Flutter dari tokens.json
Status: DONE
Owner: FE
Depends on: F0-PM-01

### Konteks
FE butuh tema Material 3 yang selaras tokens.json agar layar tidak hardcode warna/ukuran.

### Input
- design/tokens.json, design/screen-map.md, docs/contracts/stack.md

### Output
- lib/core/theme/app_colors.dart, app_spacing.dart, app_theme.dart
- lib/core/widgets/top_bar.dart, bottom_nav.dart, app_icon.dart, state_panels.dart

### Acceptance Criteria
- [x] Light + dark theme dari tokens (accent, surface, text, radius 20/14/pill)
- [x] Renders match `index.css`: topBar 96, bottomNav 80, spacing s1-s8
- [x] Tidak ada color/size hardcode di luar tema dan widget reusable

### Verification
```bash
flutter analyze
flutter test test/core/theme
```

## [F1-FE-02] Shell navigasi 4 tab dengan mock
Status: DONE (INTERIM: Chromium OK, belum di HP fisik)
Owner: FE
Depends on: F1-FE-01

### Konteks
Shell (Library, Antrean, Pack, Setelan) dulu dengan mock domain, supaya BE bisa membangun paralel. Jangan panggil FFI nyata di sini.

### Input
- design/screen-map.md, docs/contracts/ffi.md (interface saja)

### Output
- lib/main.dart (ProviderScope + MaterialApp.router / bottom nav shell)
- lib/features/library/presentation/library_page.dart (mock grid 8 stiker)
- lib/features/queue/presentation/queue_page.dart, lib/features/packs/presentation/packs_page.dart, lib/features/settings/presentation/settings_page.dart
- lib/**/domain/*.dart (interface + mock/fake)

### Acceptance Criteria
- [x] 4 tab berpindah tanpa error; setiap tab punya state loading/empty/error (StatePanel)
- [x] Library pakai StickerGrid mock + FAB sheet (Dari galeri / Bulk import)
- [x] Queue pakai mock list 3 item + toggle Auto-RMBG
- [x] Hanya `lib/**/presentation` + `lib/core` disentuh; `rust/`/`android/`/`lib/**/data` tidak disentuh

### Verification
```bash
flutter analyze
flutter test test/features/library
flutter run -d <hp fisik>   # physical device via adb, BUKAN linux/window desktop
```
- Gunakan `flutter devices` untuk deteksi HP. Jika tidak terdeteksi, lapor BLOCKED dengan output `flutter devices` + `adb devices` (jangan klaim "sudah dites" di Wayland/desktop).

### Catatan / Blocker
- Debugging di HP fisik: nyalakan USB/WiFi debugging + izinkan di HP. Verifikasi manual di HP, bukan Chrome/Linux.
- Skill: flutter-expert + clean-code + test-master. Cek Context7 untuk Riverpod v3 sebelum dipakai.
