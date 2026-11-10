# Fase 3 — Frontend
Target: Queue Monitor nyata (stream Drift) dengan tab, sumber, progres, retry.
Kontrak terkait: docs/contracts/db-schema.md, docs/contracts/ffi.md
Desain terkait: design/screen-map.md (queue)
Depends on: F2-FE-01, F2-BE-02

## [F3-FE-01] Queue Monitor nyata
Status: DONE (host-only)
Owner: FE
Depends on: F2-BE-02

### Input
- docs/contracts/db-schema.md, lib/features/data/import/*

### Output
- lib/features/queue/domain/{queue_item,queue_repository,fake_queue_repository}.dart
- lib/features/queue/data/{app_database_provider,drift_queue_repository}.dart
- lib/features/queue/presentation/{queue_providers,queue_source,queue_card,queue_tabs,queue_page}.dart
- lib/core/widgets/app_icon.dart (ikon link)
- test/features/queue/{queue_monitor_test,drift_queue_test}.dart

### Acceptance Criteria
- [x] Tab "Dalam proses" / "Baru Diimpor" dengan jumlah
- [x] Stream realtime Drift; progres %, status, pesan error
- [x] Ikon + label sumber (galeri, Pinterest, link, file)
- [x] Retry item Gagal -> Pending
- [x] loading/empty/error

### Verification
- flutter analyze bersih; flutter test test/features/queue + library + core/theme hijau

### Notes
- FE menulis di `lib/features/queue/data/**` yang secara aturan milik BE. Dicatat sebagai deviasi kepemilikan; BE wajib mereview file tersebut sebelum Fase 4.
- `appDatabaseProvider` masih `NativeDatabase.memory()`; file-backed DB + wiring `RustLib.init`/`processPending` = task integrasi HP berikutnya.
- Auto-RMBG global masih in-memory (belum ada tabel settings di kontrak).
- Chrome/HP tidak tersedia di mesin; verifikasi visual belum final.
