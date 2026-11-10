# TODO — Sticker Studio
Legenda: [PM] [FE] [BE]

## Fase 0 — Contract Freeze
- [x] [PM] Inisialisasi repo, branch `main`/`develop`, struktur `docs/`
- [x] [PM] Tulis `contracts/ffi.md` (signature 4 fungsi Rust)
- [x] [PM] Tulis `contracts/db-schema.md` (5 tabel) + aturan WAL + enum `source_type`
- [x] [PM] Tulis `contracts/manifests.md` (JSON schema extractors/presets/fonts/themes)
- [x] [PM] Tulis `contracts/stack.md` (versi, dicek via context7)
- [x] [BE] Spike: ContentProvider WhatsApp dengan 1 pack dummy (3 stiker)
- [x] [User] Desain UI/UX selesai di Figma (export Next.js)
- [x] [User] Ekstrak project Next.js ke `design/figma-export/` (tanpa node_modules, .next, .git)
- [x] [PM] Buat PNG per layar di `design/screens/`, ekstrak `tokens.json`, tulis `screen-map.md`
- [x] [FE] Ubah `tokens.json` jadi tema Flutter, buat inventaris komponen reusable

## Fase 1 — Foundation, Rust Bridge, SQLite
- [x] [BE] Init Flutter + flutter_rust_bridge
- [x] [BE] Skema Drift + migrasi
- [x] [BE] File System Manager (`app_data/`)
- [x] [BE] Registry Engine (baca manifest JSON)
- [x] [FE] Tema dari `design/tokens.json` (selaras `themes_manifest.json`), shell navigasi

## Fase 2 — Rust Image Core & Bulk Import
- [x] [BE] `encode_whatsapp_webp` (512x512, padding, loop kualitas < 100 KB)
- [x] [BE] Bulk import -> `import_queue` + Queue Watcher
- [x] [BE] Benchmark kecepatan & memori
- [x] [FE] UI Sticker Library + Gallery Picker multi-select

## Fase 3 — Share Target Universal & Queue (Galeri, Pinterest, platform lain)
- [x] [BE] `ShareReceiverActivity` (headless) menerima `image/*` (galeri, wajib), `text/plain` (URL), dan `ACTION_SEND_MULTIPLE`
- [x] [BE] Salin gambar `content://` ke `originals/` saat diterima (izin URI hanya sementara), lalu isi `import_queue`
- [x] [BE] Salin file besar/banyak di thread/worker terpisah, jangan blok activity
- [x] [BE] Deteksi `source_type` (GALLERY_SHARE, GALLERY_PICKER, PINTEREST, GENERIC_URL, DIRECT_IMAGE_LINK)
- [x] [BE] `resolve_external_media` berbasis aturan per-domain di `extractors_manifest.json` (Pinterest dulu), fallback `og:image`, dan dukung link gambar langsung (.jpg/.png/.webp)
- [x] [BE] Tangani gagal dengan jelas (butuh login / diblokir) -> status FAILED + pesan di Queue Monitor
- [x] [BE] WorkManager background download + resume DOWNLOADING
- [x] [FE] Queue Monitor (progres, Retry, toggle Auto-RMBG, ikon/label sumber: galeri, Pinterest, link lain)
- [x] [FE] Tab Inbox / Baru Diimpor

## Fase 4 — Package Manager
- [x] [FE] UI buat/edit pack, tray icon 96x96, drag-and-drop, emoji (maks 3)
- [x] [FE] Batch actions + validasi 3–30 stiker
- [x] [BE] Repository pack, auto-increment `version`, validasi syarat WA

## Fase 5 — Image Editor Core
- [x] [FE] Scene Graph, gesture multi-touch, CustomPainter
- [x] [FE] Text editor + Font Registry + Preset Engine
- [x] [FE] Undo/redo, simpan project JSON
- [x] [BE] Serialisasi/deserialisasi project JSON, render -> Rust encode

## Fase 6 — RMBG + Border
- [x] [BE] `run_rmbg_inference` (alpha mask) + uji memori model
- [x] [BE] `generate_sticker_border` (preview low-res + final full-res)
- [x] [FE] Manual brush (erase/restore), feather, magnifier loupe
- [x] [FE] Slider border real-time (debounce)

## Fase 7 — WhatsApp Integration
- [x] [BE] `StickerContentProvider` + `WhatsAppIntentChannel`
- [x] [BE] Staging exporter -> `wa_export_staging/`
- [x] [FE] Alur "Tambah ke WhatsApp" + status
- [ ] [PM] Uji WA reguler & Business

## Fase 8 — Settings, Registry Importer, Backup
- [ ] [FE] Extension Manager (import font, simpan preset)
- [ ] [BE] Backup/restore `.sstudio` (DB + WebP + project + font)
- [ ] [PM] Regresi penuh, tag rilis v1.0
