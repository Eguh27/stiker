# Fase 6 — Backend
Target: Implementasi Rust FFI untuk pemrosesan border (`generate_sticker_border`) dan inferensi model alpha mask (`run_rmbg_inference`).
Kontrak terkait: docs/contracts/ffi.md
Depends on: F5-BE-02

## [F6-BE-01] Rust Border Generator
Status: DONE
Owner: BE
Depends on: F5-BE-02

### Konteks
Membuat fungsi Rust `generate_sticker_border` yang menerima gambar input dan menghasilkan gambar dengan stroke border / feather sesuai parameter, diekspor ke output file.

### Input
- docs/contracts/ffi.md
- rust/src/api/border.rs

### Output
- rust/src/api/border.rs (implementasi lengkap dan unit test)
- Validasi memori dan performa (< 100ms untuk 512x512)

### Acceptance Criteria
- [ ] Validasi input dan parameter rentang (width 0..100, feather 0..100, valid hex)
- [ ] Menghasilkan output border di path yang ditentukan
- [ ] Dukungan mode preview (downscale) vs final
- [ ] Semua unit test Rust di `cargo test` lulus

### Verification
```bash
cargo test --manifest-path rust/Cargo.toml
```

## [F6-BE-02] Rust RMBG Inference Pipeline & Fallback
Status: DONE
Owner: BE
Depends on: F6-BE-01

### Konteks
Memperkuat `run_rmbg_inference` di Rust agar memproses alpha mask dari model ONNX atau fallback pemrosesan mask yang aman saat dijalankan di host-test/emulator.

### Output
- rust/src/api/rmbg.rs
- Unit test di Rust

### Acceptance Criteria
- [ ] Validasi eksistensi file model dan input
- [ ] Menangani error ModelNotFound / InferenceFailed tanpa panic
- [ ] Mengembalikan path output yang valid saat sukses

### Verification
```bash
cargo test --manifest-path rust/Cargo.toml
```
