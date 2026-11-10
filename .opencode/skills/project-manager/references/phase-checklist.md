# Phase Checklist — Sticker Studio

## Awal Fase

- [ ] `TODO.md` fase terkait dibaca dan dipahami.
- [ ] Desain fase tersedia di `design/screens/` dan `design/screen-map.md`.
- [ ] Kontrak ditulis atau diperbarui: `ffi.md`, `db-schema.md`, `manifests.md`, `stack.md`.
- [ ] Versi dan tanggal kontrak dicatat.
- [ ] Task dipecah per role: `fase-<n>-pm.md`, `-frontend.md`, `-backend.md`, `-qa.md`.
- [ ] Dependency dan blocker ditulis eksplisit.
- [ ] Branch `feat/fase-<n>-<agent>-<topik>` dibuat.
- [ ] Semua agent tahu file yang boleh dan tidak boleh disentuh.

## Tengah Fase

- [ ] FE dan BE hanya menyentuh area miliknya.
- [ ] Perubahan kontrak diajukan ke PM, bukan dilakukan diam-diam.
- [ ] Checklist task diperbarui setiap hari/commit.
- [ ] Blocker dicatat dengan keputusan yang dibutuhkan.
- [ ] Benchmark Rust dijalankan untuk fungsi berat.
- [ ] Tidak ada file baru > ~100 baris tanpa alasan.
- [ ] Reuse `lib/core` dan `rust/src` dicek sebelum menambah file.

## Akhir Fase

- [ ] `flutter analyze` bersih.
- [ ] `flutter test` lulus.
- [ ] `cargo fmt --check`, `cargo clippy`, `cargo test` lulus.
- [ ] Build Android debug/release lulus.
- [ ] Benchmark dan memori puncak tercatat.
- [ ] Semua acceptance criteria task terpenuhi.
- [ ] `skills/clean-code/SKILL.md` terpenuhi.
- [ ] `docs/PROGRESS.md` diperbarui.
- [ ] PR direview PM, lalu merge ke `develop`.
- [ ] Tag `v0.<n>.0` dibuat.

## Gerbang Merge

Tolak merge jika salah satu benar:

- Ada warning baru atau test gagal.
- Signature/skema berbeda dari kontrak.
- FE menyentuh `rust/`, `android/`, atau `lib/**/data`.
- BE menyentuh `lib/**/presentation`.
- Fungsi Rust berat tidak punya benchmark atau angka memori.
- UI tidak sesuai `design/` dan tidak ada persetujuan PM.
- File besar/monolitik tanpa alasan yang dicatat.
