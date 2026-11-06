# TODO — Sticker Studio
Legenda: [PM] [FE] [BE]

## Fase 0 — Contract Freeze
- [ ] [PM] Inisialisasi repo, branch `main`/`develop`, struktur `docs/`
- [ ] [PM] Tulis `contracts/ffi.md` (signature 4 fungsi Rust)
- [ ] [PM] Tulis `contracts/db-schema.md` (5 tabel) + aturan WAL + enum `source_type`
- [ ] [PM] Tulis `contracts/manifests.md` (JSON schema extractors/presets/fonts/themes)
- [ ] [PM] Tulis `contracts/stack.md` (versi, dicek via context7)
- [ ] [BE] Spike: ContentProvider WhatsApp dengan 1 pack dummy (3 stiker)
- [x] [User] Desain UI/UX selesai di Figma (export Next.js)
- [ ] [User] Ekstrak project Next.js ke `design/figma-export/` (tanpa node_modules, .next, .git)
- [ ] [PM] Buat PNG per layar di `design/screens/`, ekstrak `tokens.json`, tulis `screen-map.md`
- [ ] [FE] Ubah `tokens.json` jadi tema Flutter, buat inventaris komponen reusable

## Fase 1 — Foundation, Rust Bridge, SQLite
- [ ] [BE] Init Flutter + flutter_rust_bridge
- [ ] [BE] Skema Drift + migrasi
- [ ] [BE] File System Manager (`app_data/`)
- [ ] [BE] Registry Engine (baca manifest JSON)
- [ ] [FE] Tema dari `design/tokens.json` (selaras `themes_manifest.json`), shell navigasi

## Fase 2 — Rust Image Core & Bulk Import
- [ ] [BE] `encode_whatsapp_webp` (512x512, padding, loop kualitas < 100 KB)
- [ ] [BE] Bulk import -> `import_queue` + Queue Watcher
- [ ] [BE] Benchmark kecepatan & memori
- [ ] [FE] UI Sticker Library + Gallery Picker multi-select

## Fase 3 — Share Target Universal & Queue (Galeri, Pinterest, platform lain)
- [ ] [BE] `ShareReceiverActivity` (headless) menerima `image/*` (galeri, wajib), `text/plain` (URL), dan `ACTION_SEND_MULTIPLE`
- [ ] [BE] Salin gambar `content://` ke `originals/` saat diterima (izin URI hanya sementara), lalu isi `import_queue`
- [ ] [BE] Salin file besar/banyak di thread/worker terpisah, jangan blok activity
- [ ] [BE] Deteksi `source_type` (GALLERY_SHARE, GALLERY_PICKER, PINTEREST, GENERIC_URL, DIRECT_IMAGE_LINK)
- [ ] [BE] `resolve_external_media` berbasis aturan per-domain di `extractors_manifest.json` (Pinterest dulu), fallback `og:image`, dan dukung link gambar langsung (.jpg/.png/.webp)
- [ ] [BE] Tangani gagal dengan jelas (butuh login / diblokir) -> status FAILED + pesan di Queue Monitor
- [ ] [BE] WorkManager background download + resume DOWNLOADING
- [ ] [FE] Queue Monitor (progres, Retry, toggle Auto-RMBG, ikon/label sumber: galeri, Pinterest, link lain)
- [ ] [FE] Tab Inbox / Baru Diimpor

## Fase 4 — Package Manager
- [ ] [FE] UI buat/edit pack, tray icon 96x96, drag-and-drop, emoji (maks 3)
- [ ] [FE] Batch actions + validasi 3–30 stiker
- [ ] [BE] Repository pack, auto-increment `version`, validasi syarat WA

## Fase 5 — Image Editor Core
- [ ] [FE] Scene Graph, gesture multi-touch, CustomPainter
- [ ] [FE] Text editor + Font Registry + Preset Engine
- [ ] [FE] Undo/redo, simpan project JSON
- [ ] [BE] Serialisasi/deserialisasi project JSON, render -> Rust encode

## Fase 6 — RMBG + Border
- [ ] [BE] `run_rmbg_inference` (alpha mask) + uji memori model
- [ ] [BE] `generate_sticker_border` (preview low-res + final full-res)
- [ ] [FE] Manual brush (erase/restore), feather, magnifier loupe
- [ ] [FE] Slider border real-time (debounce)

## Fase 7 — WhatsApp Integration
- [ ] [BE] `StickerContentProvider` + `WhatsAppIntentChannel`
- [ ] [BE] Staging exporter -> `wa_export_staging/`
- [ ] [FE] Alur "Tambah ke WhatsApp" + status
- [ ] [PM] Uji WA reguler & Business

## Fase 8 — Settings, Registry Importer, Backup
- [ ] [FE] Extension Manager (import font, simpan preset)
- [ ] [BE] Backup/restore `.sstudio` (DB + WebP + project + font)
- [ ] [PM] Regresi penuh, tag rilis v1.0
