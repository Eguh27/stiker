# Screen Map — Sticker Studio

Sumber: `design/figma-export/src/App.tsx` + `src/index.css` + `design/tokens.json`
Pemilik: PM (v0.1.0, 2026-11-09)

> `design/figma-export/` adalah referensi React/Next.js (read-only). Jangan disalin mentah ke Flutter. Terjemahkan ke widget Flutter lewat peta ini.

## Layar → Fase → Widget Flutter

| Layar (App.tsx `View`) | Fase | Page Flutter | Widget reusable |
|---|---|---|---|
| `library` | F2 | `LibraryPage` | `TopBar`, `HeroCard`, `Segmented`, `StickerGrid`/`StickerCard`, `FAB` + `BottomSheet` (Dari galeri / Bulk import) |
| `gallery` | F2 | `GalleryPickerPage` | `TopBar(back)`, `PhotoGrid` multi-select, `StickyAction` (Import) |
| `queue` | F3 | `QueueMonitorPage` | `ToggleCard` (Auto-RMBG), `QueueList`/`QueueCard` + `ProgressTrack`, `RetryButton`, `PrivacyNote` |
| `packs` | F4 | `PacksPage` | `PackList`/`PackCard` (preview 3 stiker + sync label) |
| `packEditor` | F4 | `PackEditorPage` | `PackHeaderCard` (TrayIcon 96×96), field nama/pembuat, `PackEditGrid` drag-drop, `EmojiPicker` (maks 3), `ValidationCard`, `WhatsAppButton` |
| `imageEditor` | F5 | `ImageEditorPage` | `EditorShell`, `CanvasArea` (CustomPainter), `EditorActionBar` (undo/redo/layers), `EditorToolbar` (Teks/Kuas/Hapus BG/Border/Stiker) |
| `textEditor` | F5 | `TextEditorPage` | `TextCanvas`, `ControlDrawer`, `FontRow`, `StyleRow` (Outline/Shadow/Latar), `ColorRow` |
| `removeBg` | F6 | `RemoveBackgroundPage` | `CheckerCanvas`, `BrushCursor`, `Loupe`, `ModeToggle` (Erase/Restore), `Range` (size/feather) |
| `border` | F6 | `BorderEditorPage` | `BorderCanvas` (preview), `Range` (ketebalan/feather), `ColorRow` |
| `settings` | F8 | `SettingsPage` | `ProfileCard`, `SettingsGroup`/`SettingRow`, `StorageTrack`, toggle dark mode |

## Komponen bersama → `lib/core/widgets`

| React (`App.tsx`) | Flutter |
|---|---|
| `Icon` (+ `icons` map) | `AppIcon` (IconData SVG/asset, 24 grid) |
| `TopBar` | `TopBar` (eyebrow + title + back/action) |
| `BottomNav` (Library/Antrean/Pack/Setelan) | `BottomNav` (NavigationBar) |
| `StickerArt` (blob/cloud/flower/burst) | `StickerArt` placeholder (diganti WebP encoder) |
| `StatePanel` (loading/empty/error) | `LoadingState`, `EmptyState`, `ErrorState` |
| `Range` | `AppSlider` |
| `DemoStateMenu` | HANYA untuk demo web — JANGAN dibawa ke Flutter |

## Data yang dibutuhkan (kontrak)

- Library/Gallery/Queue: `db-schema.md` (`stickers`, `import_queue`), `ffi.md::encode_whatsapp_webp`
- Packs: `db-schema.md` (`packs`, `pack_stickers`)
- Queue sumber: `source_type` enum (`GALLERY_SHARE`, `GALLERY_PICKER`, `PINTEREST`, `GENERIC_URL`, `DIRECT_IMAGE_LINK`) + `extractors_manifest.json`
- Editor: `manifests.md` (`presets_manifest.json`, `fonts_manifest.json`) + `ffi.md::run_rmbg_inference` / `generate_sticker_border`

## Catatan PM

- PNG per layar di `design/screens/` masih kosong. FE pakai `App.tsx` + `index.css` sebagai referensi sampai PNG dirender dari Vite (screenshot di luar repo).
- Semua warna/spasi/radius dari `design/tokens.json`. Tidak ada hardcode di layar.
