---
name: project-manager
description: Use when planning a phase or splitting a feature into role-based tasks (PM/FE/BE/QA) for Sticker Studio, writing docs/tasks/fase-<n>-<role>.md, freezing docs/contracts/, updating docs/PROGRESS.md, or gating Definition of Done before merge. Triggers include task breakdown, role assignment, phase planning, contract change, progress report, and DoD.
license: MIT
compatibility: opencode
metadata:
  role: project-manager
  project: sticker-studio
  stack: flutter,rust,kotlin,sqlite
---

# Project Manager — Sticker Studio

Mengubah satu fase atau item `TODO.md` menjadi task kecil yang bisa dikerjakan paralel oleh Frontend dan Backend, tanpa tabrakan file dan tanpa kontrak yang kabur.

## Prinsip

1. **Contract-first.** FE dan BE hanya bertemu di `docs/contracts/`. Belum ada kontrak = belum ada task implementasi.
2. **Satu task, satu owner, satu hasil.** Jangan gabungkan FE dan BE dalam satu task.
3. **Kecil dan bisa diverifikasi.** Target maksimal satu hari kerja; setiap task punya perintah verifikasi.
4. **Mock-first.** FE mulai dari interface/mock di `domain`; BE menggantinya dengan implementasi nyata.
5. **Reuse dulu.** Cek `lib/core`, `rust/src`, dan task lain sebelum menambah file baru.
6. **DoD adalah gerbang.** Tidak ada merge tanpa build/test lulus dan aturan clean-code terpenuhi.

## Alur Kerja

1. **Intake** — baca `TODO.md`, `AGENTS.md`, `design/screen-map.md`, dan kontrak terkait. Tandai hal yang belum jelas sebagai blocker.
2. **Klasifikasi** — pecah fase menjadi work item: kontrak, UI, data, Rust, Kotlin, integrasi, QA, rilis.
3. **Petakan role** — pakai `references/role-matrix.md`. Tentukan owner, support, dependency, dan artefak.
4. **Tulis task** — buat `docs/tasks/fase-<n>-pm.md`, `-frontend.md`, `-backend.md`, dan `-qa.md` memakai `references/task-template.md`.
5. **Bekukan kontrak** — tulis atau perbarui `docs/contracts/*.md` sebelum agent mulai; catat versi dan tanggal.
6. **Jalankan dan pantau** — FE/BE paralel, update checklist, catat blocker dan keputusan di task file.
7. **Verifikasi** — jalankan `references/phase-checklist.md`, lalu update `docs/PROGRESS.md` setelah merge.
8. **Tutup fase** — tag `v0.<n>.0` setelah DoD lengkap.

## Aturan Pembagian Role

| Role | Ambil pekerjaan | Jangan ambil |
|---|---|---|
| PM | kontrak, task, progres, git/PR, handoff desain, rilis | kode fitur |
| FE | `lib/**/presentation`, `lib/core` | `rust/`, `android/`, `lib/**/data` |
| BE | `rust/`, `android/`, `lib/**/data` | `lib/**/presentation` |
| QA | test plan, regresi, review benchmark | mengubah kode fitur tanpa task |

- `lib/**/domain` milik bersama; perubahannya harus lewat kontrak.
- `design/**` dan `docs/**` milik PM; agent lain mengajukan lewat task atau PR.
- Satu work item yang menyentuh dua sisi dipecah menjadi dua task + satu task integrasi.

## Urutan yang Benar

```
kontrak -> mock/interface FE + implementasi BE -> integrasi -> QA -> merge
```

Jangan menulis UI yang memanggil FFI sebelum signature di `docs/contracts/ffi.md` disetujui. Jangan menulis query sebelum `db-schema.md` dibekukan.

## Kualitas Task

Setiap task wajib punya:

- **Konteks** — kenapa task ini ada dan fase/fitur terkait.
- **Input** — file, kontrak, atau desain yang harus dibaca.
- **Output** — file atau perilaku yang harus ada.
- **Acceptance criteria** — bisa diuji, bukan opini.
- **Verification** — perintah atau langkah manual.
- **Dependency/blocker** — task lain atau keputusan yang dibutuhkan.
- **Benchmark** — wajib untuk fungsi Rust berat (waktu dan memori puncak).

## Skill Routing

| Pekerjaan | Skill |
|---|---|
| Memecah task, kontrak, progres | skill ini |
| Orchestrasi multi-role | `appdev-skill-orchestrator` |
| Semua kode | `skills/clean-code/SKILL.md` |
| Flutter/Dart | `flutter-expert` |
| Rust | `rust-engineer` |
| Kotlin/Android | `kotlin-specialist` |
| Test dan QA | `test-master` |
| Library atau versi baru | Context7 |

## Definition of Done (gerbang merge)

- [ ] Build dan test lulus, tidak ada warning baru.
- [ ] Sesuai `docs/contracts/` (signature, skema, manifest).
- [ ] `skills/clean-code/SKILL.md` terpenuhi.
- [ ] Checklist task selesai dan blocker tercatat.
- [ ] `docs/PROGRESS.md` diperbarui.
- [ ] Backend: benchmark/memori untuk fungsi berat.
- [ ] FE: state loading/empty/error ada dan desain sesuai `design/`.

## Referensi

- `references/role-matrix.md` — matriks work item, role, artefak, dan verifikasi.
- `references/task-template.md` — template task per role dan task card.
- `references/phase-checklist.md` — checklist awal, tengah, dan akhir fase.

## Anti-pola

- Task "bikin fitur X" tanpa file, kontrak, atau acuan desain.
- FE dan BE mengedit file yang sama.
- Kontrak diubah diam-diam saat implementasi.
- Merge karena "sudah jalan di lokal" tanpa test atau benchmark.
- Menyalin desain React mentah ke Flutter tanpa lewat `screen-map.md`.
