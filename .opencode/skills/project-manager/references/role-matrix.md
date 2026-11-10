# Role Matrix — Sticker Studio

Gunakan tabel ini saat memecah fase menjadi task. Satu baris biasanya menjadi satu task, kecuali work item yang butuh task integrasi terpisah.

| Work item | Primary | Support | Artefak | Verifikasi |
|---|---|---|---|---|
| Kontrak FFI | PM | BE, FE | `docs/contracts/ffi.md` | Review signature + contoh input/output |
| Skema DB dan migrasi | BE | PM | `docs/contracts/db-schema.md`, `lib/**/data` | `dart run build_runner build`, migration test |
| Manifest registry | BE | PM | `docs/contracts/manifests.md`, parser | Unit test manifest valid/invalid |
| Tema dan token | FE | PM | `lib/core/theme` | `flutter analyze`, widget test |
| Layar dan navigasi | FE | PM (desain) | `lib/**/presentation` | `flutter analyze`, `flutter test`, bandingkan `design/screens/` |
| Widget reusable | FE | — | `lib/core/widgets` | Widget test + cek duplikasi |
| Image core Rust | BE | PM | `rust/src/{domain,api}` | `cargo test`, `cargo clippy`, criterion bench + memori |
| Border dan RMBG | BE | FE (kontrol UI) | `rust/src`, kontrak parameter | Benchmark + uji memori puncak |
| Share Target Kotlin | BE | PM | `android/**/bridge` | Build Android + uji manual share |
| ContentProvider WhatsApp | BE | PM | `android/**/bridge` | Uji manual WA reguler/Business |
| Queue watcher | BE | FE | `lib/**/data`, `domain` | Integration test + simulasi resume |
| Editor scene graph | FE | BE | `lib/**/presentation`, `domain` | Widget/gesture test + cek FPS |
| Serialisasi project JSON | BE | FE | `domain`, `lib/**/data` | Round-trip test |
| Backup/restore `.sstudio` | BE | PM | `lib/**/data` | Round-trip test + ukuran file |
| CI dan build | PM | BE | pipeline | Build debug/release lulus |
| Regresi rilis | QA | PM, FE, BE | test plan | Seluruh suite + benchmark |

## Aturan Pemecahan

1. **Satu lapisan per task.** UI, data, Rust, dan Android tidak dicampur dalam satu task.
2. **Dependency eksplisit.** Tulis `Depends on:` di task; jangan andalkan urutan daftar.
3. **Paralel aman.** FE dan BE hanya paralel jika file yang disentuh berbeda dan kontrak sudah beku.
4. **Task integrasi.** Setelah FE dan BE selesai, buat task terpisah untuk menyambungkan keduanya.
5. **Blocker PM.** Jika keputusan kontrak belum ada, task implementasi berstatus `BLOCKED`, bukan ditebak.

## Kepemilikan File

| Path | Owner |
|---|---|
| `lib/**/presentation`, `lib/core` | FE |
| `lib/**/data`, `rust/`, `android/` | BE |
| `lib/**/domain` | FE + BE lewat kontrak |
| `docs/`, `design/` | PM |
| `integration_test/`, rencana QA | QA |

## Contoh Pemecahan: Fase 2

| Task | Owner | Depends on |
|---|---|---|
| `encode_whatsapp_webp` + benchmark | BE | `contracts/ffi.md` |
| Mock encoder + UI Library | FE | `contracts/ffi.md` |
| Integrasi encoder nyata | FE + BE | Task BE dan FE selesai |
| Regresi ukuran < 100 KB | QA | Integrasi selesai |

## Contoh Pemecahan: Fase 3

| Task | Owner | Depends on |
|---|---|---|
| `ShareReceiverActivity` + salin `content://` | BE | `contracts/manifests.md` |
| Deteksi `source_type` | BE | Manifest disetujui |
| Queue Monitor + label sumber | FE | Interface queue disetujui |
| Resolusi Pinterest/`og:image` | BE | `extractors_manifest.json` |
| Uji share dari Galeri, Pinterest, link langsung | QA | Semua task di atas |
