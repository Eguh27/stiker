# Kontrak Project Schema — Sticker Project JSON

Versi: 0.1.0 — 2026-11-10 — Pemilik: PM
Status: FROZEN

## Struktur `projects.project_json`
Ukuran kanvas stiker standar: 512 × 512 px.

```json
{
  "version": 1,
  "canvas": {
    "width": 512,
    "height": 512
  },
  "layers": [
    {
      "id": "layer-1",
      "type": "image",
      "visible": true,
      "transform": {
        "x": 256.0,
        "y": 256.0,
        "scale": 1.0,
        "rotation": 0.0
      },
      "image_path": "/app_data/stickers/stk-1.webp"
    },
    {
      "id": "layer-2",
      "type": "text",
      "visible": true,
      "transform": {
        "x": 256.0,
        "y": 400.0,
        "scale": 1.0,
        "rotation": 0.0
      },
      "text": "GOOD DAY!",
      "font_family": "Montserrat",
      "font_size": 36.0,
      "color": "#282522",
      "preset_style": "Outline",
      "style_color": "#FFFFFF"
    }
  ]
}
```

## Aturan
- `id` unik per layer.
- `transform.x` dan `y` adalah titik tengah (pivot) layer relatif terhadap kanvas 512×512.
- `scale` > 0.
- `font_family` harus terdaftar di `fonts_manifest.json` (fallback: default sistem).
- `preset_style` dari `presets_manifest.json`: "None", "Outline", "Shadow", "Latar".
- Serialisasi dan deserialisasi harus lossless dan tahan terhadap field baru di masa depan.

