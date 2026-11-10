# Fase 4 — Integrasi
Target: Sambungkan Pack Editor UI (FE) ke repository pack Drift (BE) tanpa ubah kontrak.
Kontrak terkait: docs/contracts/db-schema.md v0.2.0
Depends on: F4-FE-01, F4-BE-02

## [F4-INT-01] Wiring pack repository nyata
Status: DONE
Owner: FE (implementasi) + BE (review)
Depends on: F4-FE-01, F4-BE-02, F4-BE-03

### Konteks
F4-FE-01 memakai fake (`PackEditorRepository`), F4-BE-02 memakai API data-layer yang lebih kaya (`PackRepositoryImpl`). Dua API ini harus dipertemukan lewat adapter, bukan dengan menulis ulang salah satunya.

### Gap yang harus diselesaikan
1. **Adapter API**: `PackRepositoryImpl` -> `PackEditorRepository` (fetchPacks, fetchPackDetail, createPack, updatePack, reorderStickers).
2. **Metadata stiker**: `Sticker` domain FE belum membawa `file_path`/`thumb_path`/`tray`, sedangkan data-layer butuh. Perlu pemetaan id -> baris `stickers` di adapter (bukan ubah domain tanpa kontrak).
3. **Emoji tags**: kontrak v0.3.0 sudah menambah `packs.emojis` (F4-BE-03). Adapter wajib menyimpan/membaca emoji, bukan draft-only.

### Output
- `packRepositoryProvider` mengarah ke adapter Drift; fake tetap untuk test
- test integrasi create/update/reorder + reload dari DB

### Acceptance Criteria
- [x] Editor pack memakai repository nyata, fake tetap untuk test
- [x] Pack + urutan + metadata tersimpan dan terbaca ulang setelah restart DB
- [x] Tidak ada perubahan signature domain tanpa persetujuan PM
- [x] Emoji: tersimpan dan terbaca ulang via `packs.emojis`

### Verification
```bash
flutter analyze
flutter test test/features/packs test/data/pack
```

### Catatan
- File integrasi: `lib/features/packs/presentation/**` + `lib/features/packs/domain/**` (FE), review BE.
- `lib/**/data` tetap milik BE; adapter diletakkan di `lib/features/data/pack/`.
