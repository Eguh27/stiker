# Skill Map — Sticker Studio App Dev

Pemetaan detail dari jenis pekerjaan ke role, skill, artefak, dan verifikasi.

| Pekerjaan | Role | Skill wajib | Skill pendukung | Artefak | Verifikasi |
|---|---|---|---|---|---|
| Pecah fase jadi task | PM | `project-manager` | — | `docs/tasks/fase-<n>-*.md` | Review dependency + acceptance criteria |
| Kontrak FFI | PM + BE + FE | `project-manager` | `rust-engineer`, `flutter-expert` | `docs/contracts/ffi.md` | Review signature + contoh input/output |
| Tema dari token | FE | `flutter-expert` | `clean-code` | `lib/core/theme` | `flutter analyze` |
| Layar Flutter | FE | `flutter-expert` | `clean-code`, `test-master` | `lib/**/presentation` | `flutter test`, bandingkan `design/screens/` |
| Komponen reusable | FE | `flutter-expert` | `clean-code` | `lib/core/widgets` | Widget test + cek duplikasi |
| State Riverpod/Bloc | FE | `flutter-expert` | `clean-code`, `test-master` | `lib/**/presentation`, `domain` | Unit/widget test |
| Editor kanvas/gesture | FE | `flutter-expert` | `clean-code`, `debugging-wizard` | `presentation`, `domain` | Widget test + profil FPS |
| Encode WebP | BE | `rust-engineer` | `clean-code`, `test-master` | `rust/src/api` | `cargo test`, `cargo bench` |
| Border/RMBG | BE | `rust-engineer` | `clean-code` | `rust/src` | Benchmark + memori puncak |
| Skema/migrasi Drift | BE | `sql-pro` | `clean-code`, `test-master` | `lib/**/data`, kontrak | `build_runner`, migration test |
| Query lambat | BE | `database-optimizer` | `sql-pro` | query/index | `EXPLAIN`, benchmark sebelum/sesudah |
| Share Target Android | BE | `kotlin-specialist` | `secure-code-guardian`, `clean-code` | `android/**/bridge` | `./gradlew assembleDebug`, uji manual |
| ContentProvider WhatsApp | BE | `kotlin-specialist` | `secure-code-guardian` | `android/**/bridge` | Uji WA reguler/Business |
| Queue watcher/resume | BE | `kotlin-specialist` | `clean-code`, `test-master` | `lib/**/data` | Integration test + simulasi kill |
| Bug lintas layer | Role terkait | `debugging-wizard` | skill role | perbaikan + test | Reproduksi lalu test regresi |
| Audit keamanan | BE/FE | `security-reviewer` | `secure-code-guardian` | laporan | Temuan + remediasi |
| CI/build | PM/BE | `devops-engineer` | — | pipeline | Build debug/release lulus |
| Dokumentasi FFI/API | PM/BE | `code-documenter` | — | `docs/` | Review contoh kode |
| Rilis fase | PM | `project-manager` | `test-master`, `devops-engineer` | `docs/PROGRESS.md`, tag | Seluruh suite + regresi manual |

## Kombinasi Umum

- **Fitur UI baru:** `flutter-expert` + `clean-code` + `test-master`.
- **Fitur Rust baru:** `rust-engineer` + `clean-code` + `test-master` + Context7.
- **Fitur lintas FE/BE:** `project-manager` -> kontrak -> FE/BE paralel -> integrasi -> QA.
- **Investigasi performa:** `debugging-wizard` + skill role + benchmark.
- **Persiapan rilis:** `project-manager` + `test-master` + `security-reviewer`.

## Context7

Selalu cek dokumentasi terbaru untuk:

- Flutter/Dart API dan widget baru.
- Riverpod, Drift, `flutter_rust_bridge`.
- Android API, Gradle, WorkManager.
- Crate Rust baru atau versi mayor.

## Batas Skill Web

Jangan memakai `gsap-*`, `playwright-*`, `ui-ux-pro-max`, atau skill web lain untuk implementasi Flutter. Pengecualian: membaca `design/figma-export/` sebagai referensi visual.
