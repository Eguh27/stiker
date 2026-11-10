# Kontrak FFI — Rust ↔ Flutter (flutter_rust_bridge)

Versi: 0.1.0 — 2026-11-09 — Pemilik: PM
Status: DRAFT (beku setelah review BE+FE)

## Aturan umum
- Lewatkan path file, bukan byte besar, di FFI bila bisa.
- Semua fungsi berat di worker thread / `spawn_blocking` (mode `async`, bukan `#[frb(sync)]`).
- Error dikembalikan sebagai `Result<T, FfiError>`, bukan `panic`.
- Batas WhatsApp: stiker 512×512, < 100 KB; tray icon 96×96, < 50 KB.

## Signature

### `encode_whatsapp_webp`
```rust
// rust/src/api/encode.rs
pub async fn encode_whatsapp_webp(
    input_path: String,
    output_path: String,
    target_size_kb: u32, // default 100; tray pakai 50
) -> Result<String, EncodeError>
// Return: output_path (file WebP 512x512, validasi < target_size_kb)
// Error: InputNotFound | InvalidImage | EncodeFailed | TooLargeAfterQualityLoop
```

### `generate_sticker_border`
```rust
pub async fn generate_sticker_border(
    input_path: String,
    output_path: String,
    width_px: i32,      // 0..=100, default 12
    feather_pct: i32,   // 0..=100
    color_rgba: String, // "#FFFFFF" / "#RRGGBBAA"
    preview: bool,      // true => low-res (max 256 px)
) -> Result<String, EncodeError>
```

### `run_rmbg_inference`
```rust
pub async fn run_rmbg_inference(
    input_path: String,
    output_path: String,
    model_path: String, // path model ONNX/aksen yang dikutip di stack.md
) -> Result<String, InferenceError>
// Return: output_path PNG RGBA dengan alpha mask
// Error: ModelNotFound | InferenceFailed | OOM
```

### `resolve_external_media`
```rust
pub async fn resolve_external_media(
    url: String,
    output_path: String,
    extractors_manifest_path: String,
) -> Result<String, ResolveError>
// Aturan per-domain dari extractors_manifest.json (Pinterest dulu),
// fallback og:image, dukung link langsung .jpg/.png/.webp
// Error: NeedsLogin | Blocked | NotFound | UnsupportedType
```

## Contoh
```
encode_whatsapp_webp("/app_data/originals/a.jpg", "/app_data/stickers/a.webp", 100) -> Ok("/app_data/stickers/a.webp")
```

## Riwayat
- 0.1.0 (2026-11-09): draft awal 4 fungsi dari TODO Fase 1/2/6.
