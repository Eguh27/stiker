# Kontrak WhatsApp Provider & Intent Channel

Versi: 0.1.0 — 2026-11-10 — Pemilik: PM
Status: FROZEN (acuan Fase 7)

## 1. Arsitektur Integrasi WhatsApp
WhatsApp untuk Android membaca stiker melalui `ContentProvider` resmi dari aplikasi pihak ketiga dan memicu dialog instalasi stiker via Intent `com.whatsapp.intent.action.ENABLE_STICKER_PACK`.

## 2. ContentProvider Contract
- **Authority:** `com.example.sticker_studio.stickercontentprovider`
- **Class:** `com.example.sticker_studio.provider.StickerContentProvider`

### URI Paths:
1. `content://com.example.sticker_studio.stickercontentprovider/metadata`
   - Query daftar semua pack stiker yang tersedia untuk WhatsApp.
   - Kolom Cursor:
     - `sticker_pack_identifier` (Text)
     - `sticker_pack_name` (Text)
     - `sticker_pack_publisher` (Text)
     - `sticker_pack_icon` (Text)
     - `android_play_store_link` (Text, nullable)
     - `ios_app_store_link` (Text, nullable)
     - `publisher_email` (Text, nullable)
     - `publisher_website` (Text, nullable)
     - `privacy_policy_website` (Text, nullable)
     - `license_agreement_website` (Text, nullable)
     - `image_data_version` (Text)
     - `avoid_cache` (Integer: 0 / 1)
     - `animated_sticker_pack` (Integer: 0 / 1)

2. `content://com.example.sticker_studio.stickercontentprovider/stickers/<identifier>`
   - Query daftar stiker dalam satu pack.
   - Kolom Cursor:
     - `sticker_file_name` (Text)
     - `sticker_pack_identifier` (Text)
     - `sticker_emojis` (Text: JSON array string, contoh `["😀", "🔥"]`)

3. `content://com.example.sticker_studio.stickercontentprovider/stickers_asset/<identifier>/<file_name>`
   - Buka file WebP fisik via `openAssetFile` / `ParcelFileDescriptor`.
   - Mengarahkan ke file di `wa_export_staging/<identifier>/<file_name>`.

## 3. Staging Exporter Contract
Sebelum memicu intent ke WhatsApp, aplikasi mengekspor pack ke direktori staging:
- Folder: `<app_files_dir>/wa_export_staging/<identifier>/`
- Struktur berkas:
  - `metadata.json`: Informasi pack + daftar stiker & emoji
  - `tray.png` / `tray.webp`: Ukuran 96×96 px, budget < 50 KB
  - `<filename>.webp`: Ukuran 512×512 px, budget < 100 KB (minimal 3, maksimal 30 stiker)

## 4. MethodChannel: `com.example.sticker_studio/whatsapp`
- `isWhatsAppInstalled(Map { "package": "com.whatsapp" | "com.whatsapp.w4b" }) -> bool`
- `addStickerPack(Map { "identifier": String, "name": String, "isBusiness": bool }) -> bool`
- `getStagingDirectory() -> String`

