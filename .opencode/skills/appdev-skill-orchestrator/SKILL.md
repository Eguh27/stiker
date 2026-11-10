---
name: appdev-skill-orchestrator
description: Use at the start of any Sticker Studio app-development task (Flutter/Dart UI, Rust worker, Kotlin/Android bridge, SQLite/Drift, flutter_rust_bridge) to choose and sequence the right installed skills and role agents (PM/FE/BE/QA). Use when a task crosses frontend/backend boundaries, when several skills plausibly apply, or when unsure which skill to load. This is a router only — it selects skills and workflow, it does not implement.
license: MIT
compatibility: opencode
metadata:
  role: orchestrator
  project: sticker-studio
  stack: flutter,rust,kotlin,sqlite
---

# App Dev Skill Orchestrator

Padanan `webdev-skill-orchestrator` untuk aplikasi native/offline-first. Skill ini memilih skill dan urutan kerja; implementasi tetap dilakukan skill atau agent yang dipilih.

**Gunakan di awal task app-dev. Jangan memuat semua skill sekaligus.**

## Beda dengan Webdev

| Webdev | Appdev |
|---|---|
| Browser, DOM, CSS, GSAP | Widget Flutter, state, kanvas, gesture |
| Playwright untuk verifikasi | `flutter analyze`, `flutter test`, emulator/perangkat |
| Next.js/React | Flutter + Rust FFI + Kotlin Android |
| Bundle JS | Ukuran APK, memori, FPS, benchmark Rust |

Untuk pekerjaan di `design/figma-export/`, pakai `webdev-skill-orchestrator`. Folder itu hanya referensi desain, bukan bagian app.

## Role Agents

Persona lengkap ada di `agents/`. Orchestrator memilih role, lalu memakai subagent yang tersedia di harness ini.

| Role | Fokus | Persona |
|---|---|---|
| PM | kontrak, pemecahan task, progres, merge gate | `agents/project-manager.md` |
| FE | `lib/**/presentation`, `lib/core` | `agents/frontend.md` |
| BE | `rust/`, `android/`, `lib/**/data` | `agents/backend.md` |
| QA | test plan, regresi, benchmark review | `agents/project-manager.md` (bagian verifikasi) |

**Subagent yang tersedia:** `explore`/`explorer` untuk pencarian cepat, `general` untuk pekerjaan multi-langkah. Jangan memakai nama agent dari `orchestration-workflow` generik (`coder-agent`, `builder-agent`, dan sejenisnya) karena tidak ada di harness ini.

## Katalog Skill

| Skill | Pakai saat |
|---|---|
| `project-manager` | Memecah fase, menulis task/kontrak, update progres, cek DoD |
| `skills/clean-code/SKILL.md` | **Wajib** untuk setiap perubahan kode |
| `flutter-expert` | Widget, Riverpod/Bloc, GoRouter, animasi, performa Flutter |
| `rust-engineer` | Ownership, FFI, async, error handling, performa Rust |
| `kotlin-specialist` | Kotlin/Android bridge, coroutine, Compose |
| `sql-pro` | Skema SQLite, query, index, migrasi sulit |
| `database-optimizer` | Query lambat atau analisis execution plan |
| `architecture-designer` | Keputusan arsitektur besar atau ADR |
| `test-master` | Strategi unit/widget/integration test dan benchmark |
| `debugging-wizard` | Stack trace, crash, bug sulit, perilaku flaky |
| `secure-code-guardian` | Izin Android, penyimpanan file, input tidak tepercaya |
| `security-reviewer` | Audit keamanan eksplisit sebelum rilis |
| `devops-engineer` | CI, Gradle, pipeline build Flutter/Android |
| `code-documenter` | Dokumentasi API/FFI dan panduan |
| `context7-mcp` | Dokumentasi library/API/versi terbaru |

## Aturan Pemilihan

1. **Explicit invocation menang.** Jika user memanggil skill tertentu, pakai itu lebih dulu.
2. **`clean-code` selalu ikut** untuk task yang menulis atau mengubah kode.
3. **Satu skill role utama.** FE memakai `flutter-expert`; BE Rust memakai `rust-engineer`; BE Android memakai `kotlin-specialist`.
4. **Tambah skill lintas-area hanya jika relevan** (test, security, performance, dokumentasi).
5. **Context7 sebelum memakai library/API baru.**
6. **Jangan memuat skill web** untuk task Flutter/Rust, kecuali sedang membaca `design/figma-export/`.

## Routing Cepat

| Task | Skill |
|---|---|
| Layar/komponen Flutter | `flutter-expert` + `clean-code` |
| Editor kanvas, gesture, 60 FPS | `flutter-expert` + `clean-code` + `test-master` |
| Encode WebP, border, RMBG | `rust-engineer` + `clean-code` + `test-master` |
| FFI baru atau ubah signature | `project-manager` + `rust-engineer` + `flutter-expert` |
| Skema Drift/SQLite | `sql-pro` + `clean-code` |
| Share Target / ContentProvider | `kotlin-specialist` + `secure-code-guardian` + `clean-code` |
| Bug lintas layer | `debugging-wizard` + skill role terkait |
| Rilis fase | `project-manager` + `test-master` + `devops-engineer` |
| Library/versi baru | Context7 + skill role terkait |

## Alur Orchestrasi

```
Intake -> Klasifikasi -> PM pecah task -> Bekukan kontrak
      -> FE & BE paralel -> Integrasi -> Verifikasi -> Review DoD -> Merge
```

1. **Intake** — baca `AGENTS.md`, `TODO.md`, `docs/contracts/`, dan `design/screen-map.md`. Gunakan `explore` untuk mencari file terkait.
2. **Klasifikasi** — tentukan apakah task menyentuh FE, BE, atau keduanya. Jika keduanya, wajib ada kontrak dan task integrasi.
3. **Pecah task** — muat `project-manager`; hasilnya `docs/tasks/fase-<n>-<role>.md`.
4. **Bekukan kontrak** — PM menulis/memperbarui kontrak sebelum implementasi.
5. **Eksekusi paralel** — spawn `general` untuk FE dan BE hanya jika file yang disentuh berbeda. Sertakan path, kontrak, batas kepemilikan, dan perintah verifikasi di prompt.
6. **Integrasi** — sambungkan FE dan BE lewat interface/kontrak, bukan saling mengedit file.
7. **Verifikasi** — jalankan matriks verifikasi di bawah. Jangan klaim lulus tanpa menjalankan perintah.
8. **Review DoD** — PM memeriksa checklist dan clean-code sebelum merge.

## Aturan Spawn Subagent

- **`explore`** — pencarian file/simbol cepat, satu pertanyaan, hasil ringkas.
- **`general`** — implementasi multi-file, refactor, investigasi mendalam.
- **Background** — hanya untuk pekerjaan independen yang bisa berjalan sambil kita mengerjakan hal lain.
- **Prompt wajib memuat** — tujuan, file yang boleh disentuh, kontrak terkait, acceptance criteria, perintah verifikasi, dan format laporan.
- **Jangan spawn dua agent untuk file yang sama.**

Template prompt ada di `references/subagent-prompts.md`.

## Matriks Verifikasi

| Area | Perintah |
|---|---|
| Flutter | `flutter analyze`, `flutter test` |
| Integrasi Flutter | `flutter test integration_test` |
| Rust | `cargo fmt --check`, `cargo clippy --all-targets --all-features`, `cargo test` |
| Rust berat | `cargo bench` + catat waktu dan memori puncak |
| Android | `./gradlew lint`, `./gradlew assembleDebug` dari `android/` |
| Drift | `dart run build_runner build --delete-conflicting-outputs` + migration test |
| Rilis | build release + regresi manual WhatsApp |

## Aturan Context7

Gunakan Context7 untuk Flutter, Dart, Riverpod, Drift, flutter_rust_bridge, Android API, dan crate/library baru. Jangan mengandalkan ingatan model untuk signature atau versi.

## Aturan Desain

- `design/screens/`, `design/tokens.json`, dan `design/screen-map.md` adalah sumber kebenaran visual.
- `design/figma-export/` hanya referensi React/Next.js; jangan disalin mentah ke Flutter.
- `design/**` read-only untuk FE/BE.

## Anti-pola

- Memakai skill web/GSAP/Playwright untuk task Flutter.
- Spawn agent generik dari `orchestration-workflow` yang tidak ada di harness.
- FE dan BE mengedit file yang sama.
- Menulis FFI call sebelum kontrak disetujui.
- Mengklaim "sudah dites" tanpa menjalankan perintah verifikasi.
- Memuat semua skill sekaligus.

## Referensi

- `references/skill-map.md` — pemetaan task, role, skill, artefak, verifikasi.
- `references/subagent-prompts.md` — template prompt untuk `explore` dan `general`.
