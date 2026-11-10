# Kontrak Manifest — Registry (JSON)

Versi: 0.1.0 — 2026-11-09 — Pemilik: PM
Status: DRAFT

## File (di `app_data/registry/`, dibaca `Registry Engine` BE)

- `extractors_manifest.json` — aturan per-domain untuk `resolve_external_media` (Pinterest dulu).
  ```json
  {
    "version": 1,
    "extractors": [
      { "domain": ["pinterest.com", "pin.it"], "strategy": "og_image", "needs_login": false }
    ]
  }
  ```
- `presets_manifest.json` — preset gaya teks (Fase 5): id, name, stroke, shadow, background.
- `fonts_manifest.json` — font terdaftar (Fase 5/8): id, family, file, license_note.
- `themes_manifest.json` — tema aplikasi selaras `design/tokens.json`.

## Aturan
- BE tidak hardcode aturan Pinterest. Semua lewat manifest.
- Parser gagal = error, bukan fallback diam-diam.
- Versi mayor manifest = breaking; dicatat di Riwayat.

## Riwayat
- 0.1.0 (2026-11-09): skema awal dari TODO Fase 0.
