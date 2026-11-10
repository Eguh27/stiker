# Task Template — Sticker Studio

Gunakan template ini agar setiap agent mendapat konteks yang sama dan tidak menebak.

## Header Fase

```markdown
# Fase <n> — <Role>
Target: <satu kalimat yang bisa diukur>
Kontrak terkait: <link ke docs/contracts/*.md>
Desain terkait: <link ke design/screens/* atau screen-map.md>
Depends on: <task/fase lain atau ->
```

## Task Card

````markdown
## [F<n>-<ROLE>-<NN>] <Judul task>

Status: TODO | IN_PROGRESS | BLOCKED | DONE
Owner: FE | BE | PM | QA
Depends on: <task id atau ->

### Konteks
<kenapa task ini ada; kaitkan dengan fase/fitur>

### Input
- <file/kontrak/desain yang wajib dibaca>

### Output
- <file/perilaku yang harus ada>

### Acceptance Criteria
- [ ] <kriteria yang bisa diuji>
- [ ] <kriteria kedua>

### Verification
```bash
<perintah verifikasi>
```

### Benchmark (khusus BE fungsi berat)
- Waktu: <target, mis. encode 4K < 800 ms>
- Memori puncak: <target, mis. < 300 MB>

### Catatan / Blocker
- <keputusan, risiko, atau hal yang menunggu PM>
````

## Contoh File Frontend

````markdown
# Fase 2 — Frontend
Target: UI Sticker Library + Gallery Picker multi-select memakai encoder mock.
Kontrak terkait: docs/contracts/ffi.md
Desain terkait: design/screens/library.png, design/screen-map.md
Depends on: F2-PM-01 (kontrak beku)

## [F2-FE-01] Sticker Library dengan mock encoder
Status: TODO
Owner: FE
Depends on: F2-PM-01

### Input
- design/screens/library.png
- design/tokens.json
- docs/contracts/ffi.md

### Output
- lib/features/library/presentation/library_page.dart
- lib/features/library/domain/sticker_encoder.dart (interface + mock)

### Acceptance Criteria
- [ ] Grid stiker responsif, memakai widget dari lib/core/widgets
- [ ] State loading, empty, dan error tersedia
- [ ] Tidak ada warna/ukuran hardcode di luar tema

### Verification
```bash
flutter analyze
flutter test test/features/library
```
````

## Contoh File Backend

````markdown
# Fase 2 — Backend
Target: encode_whatsapp_webp 512x512 dengan target < 100 KB dan benchmark tercatat.
Kontrak terkait: docs/contracts/ffi.md
Depends on: F2-PM-01

## [F2-BE-01] encode_whatsapp_webp + benchmark
Status: TODO
Owner: BE
Depends on: F2-PM-01

### Input
- docs/contracts/ffi.md
- rust/src/api

### Output
- rust/src/api/encode.rs
- rust/benches/encode_bench.rs

### Acceptance Criteria
- [ ] Output selalu 512x512 WebP
- [ ] Ukuran < 100 KB untuk seluruh fixture
- [ ] Error dikembalikan sebagai Result, bukan panic

### Verification
```bash
cargo fmt --check
cargo clippy --all-targets --all-features
cargo test
cargo bench --bench encode_bench
```

### Benchmark
- Waktu: < 800 ms untuk input 4K
- Memori puncak: < 300 MB
````

## Contoh File QA

````markdown
# Fase <n> — QA
Target: regresi fitur fase <n>.
Kontrak terkait: <link>

## [F<n>-QA-01] Regresi <fitur>
Status: TODO
Owner: QA

### Skenario
- [ ] Jalur utama
- [ ] Input tidak valid
- [ ] Proses dimatikan OS lalu resume
- [ ] Ukuran/batas WhatsApp

### Verification
```bash
flutter test
cargo test
```
````

## Baris PROGRESS

```markdown
| <n> | <status FE> | <status BE> | <Belum/Proses/Selesai> | <branch/PR> | <tanggal + catatan> |
```

## Format Laporan Agent ke PM

```markdown
Status: DONE | BLOCKED | NEEDS_CONTRACT
Files: <daftar file yang berubah>
Verification: <perintah + hasil ringkas>
Notes: <blocker, keputusan, atau angka benchmark>
```
