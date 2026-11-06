# Sticker Studio — Agent Guide

Aplikasi pembuat stiker WhatsApp, offline-first. Stack: Flutter (UI) + Rust via flutter_rust_bridge (worker) + Thin Kotlin (Share Target, ContentProvider) + SQLite (Drift).
Sumber kebenaran desain: `Master Blueprint v1.0`. Detail tugas: `TODO.md`.

## Agent
| Agent | File | Fokus |
|---|---|---|
| Project Manager | `agents/project-manager.md` | Progres, git, contract, task |
| Frontend | `agents/frontend.md` | UI/UX Flutter, editor, state |
| Backend | `agents/backend.md` | Rust, SQLite, Kotlin, registry, performa memori |

## Struktur Repo
```
design/
  figma-export/      # project Next.js hasil Figma, apa adanya (read-only, tanpa node_modules/.next/.git)
  screens/           # PNG tiap layar (2x), acuan visual utama
  tokens.json        # warna, tipografi, spasi, radius (diekstrak dari tailwind.config/globals.css)
  screen-map.md      # layar -> fitur -> komponen React -> widget Flutter
docs/
  PROGRESS.md        # status per fase (PM)
  contracts/         # ffi.md, db-schema.md, manifests.md, stack.md (PM)
  tasks/             # fase-<n>-<agent>.md (PM)
lib/
  core/              # util, tema, widget reusable
  features/<fitur>/{presentation,domain,data}
rust/src/{api,domain,infra}
android/.../bridge/
```

## Aturan Kepemilikan
- Folder `lib/**/presentation` -> Frontend. `lib/**/data`, `rust/`, `android/` -> Backend. `lib/**/domain` -> disepakati lewat contract.
- `design/**` -> hanya PM yang menaruh hasil export Figma. Frontend membaca, tidak mengubah. `design/figma-export/` hanya referensi: jangan dijalankan atau di-build sebagai bagian app.
- `docs/**` -> hanya PM yang mengubah (agent lain mengajukan lewat PR/issue).
- Frontend & Backend hanya bertemu di `docs/contracts/`. Ubah kontrak = ajukan ke PM dulu.

## Git
- Branch: `main` (stabil), `develop`, `feat/fase-<n>-<agent>-<topik>`.
- Commit kecil, prefix: `feat(fe):`, `feat(be):`, `fix(...)`, `chore(pm):`, `docs(pm):`.
- Merge ke `develop` hanya lewat PR yang disetujui PM.

## Alur Kerja per Fase
1. PM menulis `docs/tasks/fase-<n>-*.md` + memperbarui kontrak, dan memastikan desain Figma fase itu sudah ada di `design/`.
2. Backend & Frontend bekerja paralel (Frontend pakai mock dari interface).
3. Agent update checklist task + lapor ke PM.
4. PM verifikasi Definition of Done, merge, update `docs/PROGRESS.md`.

## Definition of Done (semua fase)
- Build & test lulus, tanpa warning baru.
- Sesuai kontrak di `docs/contracts/`.
- Mengikuti skill `skills/clean-code/SKILL.md`.
- Backend: ada benchmark/uji memori untuk fungsi berat.

## Wajib
Semua agent mengikuti `skills/clean-code/SKILL.md` untuk setiap baris kode.
