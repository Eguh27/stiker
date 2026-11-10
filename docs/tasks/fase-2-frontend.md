# Fase 2 — Frontend
Target: UI Sticker Library responsif + Gallery Picker multi-select (mock encoder).
Kontrak terkait: docs/contracts/ffi.md (interface saja), design/screen-map.md
Desain terkait: design/screens (via App.tsx library + gallery)
Depends on: F1-FE-01 (tema)

## [F2-FE-01] Library responsif + Gallery Picker multi-select
Status: DONE (host-only, HP ditunda)
Owner: FE
Depends on: F1-FE-01

### Input
- design/tokens.json, design/screen-map.md

### Output
- lib/core/theme/app_spacing.dart (breakpoint + kolom)
- lib/features/library/presentation/{sticker_grid, gallery_providers, photo_grid, photo_tile, sticky_action, gallery_picker_page, import_sheet, import_option}.dart
- fix Column(min) di queue/packs/settings cards
- test/features/library/gallery_picker_test.dart

### Acceptance Criteria
- [x] Grid responsif 2/3/4, gallery 3/4/6
- [x] Multi-select + Pilih semua/Hapus semua + Import disabled saat 0
- [x] loading/empty/error via AsyncValue+retry
- [x] Tanpa hardcode di luar tema

### Verification
- flutter analyze: No issues found
- flutter test test/features/library: 12 passed

### Notes
- Hanya lib/**/presentation + lib/core. Chrome/HP fisik belum teruji (hanya Linux desktop).
