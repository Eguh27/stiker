# Kontrak Stack — Versi & Verifikasi

Versi: 0.1.0 — 2026-11-09 — Pemilik: PM
Status: DRAFT (angka di bawah dari `pubspec.yaml`/`Cargo.toml` saat ini; WAJIB diverifikasi via Context7 sebelum upgrade)

## Dart / Flutter
- Flutter SDK: `^3.13.4` (environment.sdk)
- `flutter_rust_bridge`: `2.13.0`
- `flutter_riverpod`: `^3.4.3`
- `drift`: `^2.35.3`, `drift_dev`: `^2.35.2`, `build_runner`: `^2.17.1`
- `path_provider`: `^2.1.6`, `path`: `^1.9.1`
- `crypto`: `^3.0.8` (SHA-256 stiker, ditambah F2-BE-02, wajib verifikasi Context7)
- `sqlite3_flutter_libs`: `^0.6.0+eol`
- `flutter_lints`: `^6.0.0`

## Rust
- Edition: `2021`
- `flutter_rust_bridge = "=2.13.0"`
- `image = "0.25.10"`, `webp = "0.3.1"`, `regex = "1.13.1"`
- `reqwest = "0.13.5"`, `serde = "1.0.229"`, `serde_json = "1.0.154"`

## Aturan
- Library/API/versi baru WAJIB cek Context7 (`resolve-library-id` lalu `query-docs`) dan catat di sini.
- Aturan clean-code: tidak ada library baru tanpa verifikasi.

## Riwayat
- 0.1.0 (2026-11-09): inventaris versi awal repo.
- 0.1.1 (2026-11-09): tambah `crypto ^3.0.8` (SHA-256, F2-BE-02); verifikasi Context7 menyusul sebelum rilis.
