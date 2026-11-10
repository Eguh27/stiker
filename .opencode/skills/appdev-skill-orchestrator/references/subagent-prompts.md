# Subagent Prompts — Sticker Studio

Gunakan template ini saat mendelegasikan pekerjaan. Ganti bagian dalam `<...>`.

## Aturan Umum

- Satu agent = satu role = satu set file.
- Sertakan path absolut/relatif yang jelas.
- Sebutkan kontrak dan batas kepemilikan file.
- Minta agent melaporkan status, file, verifikasi, dan blocker.
- Jangan menyuruh agent "menyelesaikan seluruh fitur" tanpa acceptance criteria.

## Template: Eksplorasi (`explore`)

```text
Peran: eksplorer kode (read-only).
Tugas: <pertanyaan spesifik>.
Cari di: <folder/file>.
Keluaran: daftar file + simbol + ringkasan 5 baris.
Jangan mengubah file apa pun.
```

## Template: Frontend (`general`)

```text
Peran: Frontend Sticker Studio (lihat agents/frontend.md).
Tugas: <task id dan judul>.
Baca dulu:
- docs/contracts/<kontrak>.md
- design/screen-map.md
- design/screens/<layar>.png
- design/tokens.json
Boleh disentuh: lib/**/presentation, lib/core.
Jangan disentuh: rust/, android/, lib/**/data.
Ikuti: skills/clean-code/SKILL.md dan skill flutter-expert.
Acceptance criteria:
- <kriteria 1>
- <kriteria 2>
Verifikasi:
- flutter analyze
- flutter test <path>
Laporkan: Status (DONE/BLOCKED/NEEDS_CONTRACT), file, hasil verifikasi, blocker.
```

## Template: Backend (`general`)

```text
Peran: Backend Sticker Studio (lihat agents/backend.md).
Tugas: <task id dan judul>.
Baca dulu:
- docs/contracts/<kontrak>.md
- rust/src atau lib/**/data terkait
Boleh disentuh: rust/, android/, lib/**/data.
Jangan disentuh: lib/**/presentation.
Ikuti: skills/clean-code/SKILL.md dan skill rust-engineer atau kotlin-specialist.
Acceptance criteria:
- <kriteria 1>
- <kriteria 2>
Verifikasi:
- cargo fmt --check
- cargo clippy --all-targets --all-features
- cargo test
- cargo bench <bench> (jika fungsi berat)
Laporkan: Status, file, hasil verifikasi, waktu/memori, blocker.
```

## Template: Integrasi (`general`)

```text
Peran: Integrator FE+BE.
Tugas: sambungkan <interface> ke implementasi nyata.
Kontrak: docs/contracts/<kontrak>.md.
Boleh disentuh: <file integrasi saja>.
Jangan mengubah signature publik atau skema tanpa persetujuan PM.
Verifikasi:
- flutter test <path>
- cargo test
Laporkan: Status, file, hasil verifikasi, deviasi kontrak.
```

## Template: QA (`general`)

```text
Peran: QA Sticker Studio.
Tugas: regresi fase <n>.
Baca: docs/tasks/fase-<n>-qa.md dan kontrak terkait.
Jangan mengubah kode fitur; hanya test dan laporan.
Skenario:
- jalur utama
- input tidak valid
- proses dimatikan OS lalu resume
- batas ukuran WhatsApp
Verifikasi: <perintah>.
Laporkan: tabel skenario PASS/FAIL + bukti.
```

## Format Laporan Balik

```markdown
Status: DONE | BLOCKED | NEEDS_CONTRACT
Files: <daftar file>
Verification: <perintah + hasil ringkas>
Benchmark: <waktu/memori, jika ada>
Notes: <blocker atau keputusan yang dibutuhkan PM>
```
