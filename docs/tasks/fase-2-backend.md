# Fase 2 — Backend
Target: encode_whatsapp_webp 512x512 <100KB + bulk import queue (spawn berurutan).
Kontrak terkait: docs/contracts/ffi.md, docs/contracts/db-schema.md
Depends on: F1-BE-01, F1-BE-04

## [F2-BE-01] encode_whatsapp_webp
Status: DONE (host-only)
Owner: BE
Depends on: F1-BE-04

### Input
- docs/contracts/ffi.md

### Output
- rust/src/api/encode.rs, rust/src/domain/encode_pipeline.rs (+ tests)
- rust/benches/encode_bench.rs

### Acceptance Criteria
- [x] Output 512x512 proporsional center pad transparan, EXIF orient
- [x] Quality loop 90->0, strict < target (100KB & tray 50KB lulus)
- [x] Error Result bukan panic; path-based FFI
- [x] spawn_blocking_with untuk CPU berat

### Verification
- cargo fmt --check, clippy, test 26 passed, bench mean 39.2ms (1024x768->512)

### Benchmark
- Waktu: mean 39.2ms / encode
- Memori: belum diukur puncak (catat)

## [F2-BE-02] Bulk import -> import_queue + Queue Watcher
Status: DONE (host-only)
Owner: BE
Depends on: F2-BE-01

### Input
- docs/contracts/db-schema.md, F2-BE-01 output

### Output
- lib/features/data/import/{bulk_import_repository, import_queue_store, import_queue_watcher, sticker_import_processor, imported_sticker_store}.dart
- 8 test file di test/data/import/

### Acceptance Criteria
- [x] Salin ke originals/, isi import_queue PENDING->DONE/FAILED
- [x] Resume setelah proses mati (DOWNLOADING/PROCESSING reset ke PENDING)
- [x] Bulk 30 file tidak freeze UI (sekuensial + yield event loop)

### Verification
- flutter test test/data: 60 passed; full suite 88 passed; analyze clean; format bersih (uji 3x stabil)

### Notes
- crypto ^3.0.8 ditambahkan (SHA-256), dicatat di stack.md.
- thumb_path sementara = file_path.
- Wiring app-level (RustLib.init + processPending) belum — di luar lib/**/data, jadi task integrasi berikutnya.
