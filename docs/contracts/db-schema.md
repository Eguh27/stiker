# Kontrak DB — SQLite (Drift)

Versi: 0.3.0 — 2026-11-10 — Pemilik: PM
Status: DRAFT (butuh persetujuan BE+FE sebelum dipakai)

## Aturan
- WAL mode + `busy_timeout = 5000`.
- Kotlin hanya `INSERT` ke `import_queue` (tidak UPDATE skema lain).
- `lib/**/domain` adalah jembatan FE/BE — perubahan di sini wajib lewat PM.

## Tabel (6)

1. `packs (id TEXT PK, name TEXT, author TEXT, tray_icon_path TEXT, version TEXT, is_synced INTEGER, emojis TEXT NOT NULL DEFAULT '[]', created_at INTEGER, updated_at INTEGER)` — `emojis` = JSON array string, maks 3, divalidasi repository.
2. `stickers (id TEXT PK, file_path TEXT, thumb_path TEXT, width INTEGER, height INTEGER, size_kb INTEGER, sha256 TEXT, source_type TEXT, created_at INTEGER)`
3. `pack_stickers (pack_id TEXT FK, sticker_id TEXT FK, position INTEGER, PRIMARY KEY(pack_id, sticker_id))`
4. `import_queue (id TEXT PK, source_url TEXT NULL, local_input_path TEXT NULL, source_type TEXT, status TEXT, progress INTEGER, error_message TEXT NULL, auto_rmbg INTEGER, created_at INTEGER, updated_at INTEGER)`
5. `projects (id TEXT PK, sticker_id TEXT FK, project_json TEXT, updated_at INTEGER)`
6. `app_settings (key TEXT PK, value TEXT, updated_at INTEGER)` — setting global persist (mis. `auto_rmbg`), menggantikan in-memory.

## Enum
- `source_type`: `GALLERY_SHARE`, `GALLERY_PICKER`, `PINTEREST`, `GENERIC_URL`, `DIRECT_IMAGE_LINK`, `MANUAL_FILE`
- `status` (`import_queue`): `PENDING`, `DOWNLOADING`, `PROCESSING`, `FAILED`, `DONE`

## Riwayat
- 0.1.0 (2026-11-09): draft 5 tabel dari TODO Fase 0.
- 0.2.0 (2026-11-10): tambah `app_settings` untuk Auto-RMBG global persist (temuan F3-FE-01). `thumb_path = file_path` sampai generator thumbnail ada.
- 0.3.0 (2026-11-10): tambah `packs.emojis` (JSON array, maks 3) karena tag emoji wajib untuk metadata pack WhatsApp dan saat ini hilang saat reload (temuan F4-FE-01).
