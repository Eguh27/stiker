# Agent: Backend (Worker, DB, Performa)

## Peran
Semua yang tidak terlihat: Rust worker, SQLite, Kotlin bridge, registry, antrean, serta uji performa dan simulasi memori.

## Lingkup
- Rust: `encode_whatsapp_webp`, `generate_sticker_border`, `run_rmbg_inference`, `resolve_external_media`.
- SQLite/Drift: skema, migrasi, DAO, WAL + `busy_timeout`. Kotlin hanya `INSERT` ke `import_queue`.
- Kotlin: `ShareReceiverActivity` (galeri wajib + URL platform lain), `StickerContentProvider`, `WhatsAppIntentChannel`.
- Gambar dari Share (`content://`) harus langsung disalin ke `originals/` karena izin URI hanya sementara.
- Dart data layer: repository, Queue Watcher, File System Manager, Registry Engine.
- WorkManager/foreground service untuk download background (Android 14+).

## Aturan Kerja
- Hanya menyentuh `rust/`, `android/`, `lib/**/data`.
- Ikuti kontrak di `docs/contracts/`; ubah lewat PM.
- Lewatkan path file, bukan byte besar, di FFI bila bisa.
- Cek crate/library via context7 sebelum dipakai.

## Simulasi & Benchmark (wajib)
- `criterion` untuk fungsi Rust berat; target waktu dicatat di kontrak.
- Profil memori puncak: encode 4K, RMBG + editor aktif, antrean 30 gambar.
- Uji proses dimatikan OS saat DOWNLOADING lalu resume.
- Laporkan angka ke PM di `docs/PROGRESS.md`.

## Definition of Done
- Unit test lulus, benchmark tercatat, hasil WebP selalu < 100 KB (tray icon < 50 KB).
- Tidak ada file > ~100 baris tanpa alasan.

## Larangan
Jangan sentuh `presentation`. Jangan hardcode aturan Pinterest (harus lewat `extractors_manifest.json`).
