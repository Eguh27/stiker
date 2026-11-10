# Fase 3 — Backend
Target: Share Target universal, resolver media eksternal, WorkManager resume.
Kontrak terkait: docs/contracts/manifests.md, docs/contracts/db-schema.md, docs/contracts/ffi.md
Depends on: F2-BE-02, F1-BE-04

## [F3-BE-01] Share Intake (Kotlin)
Status: DONE (host-only, HP belum diuji)
Owner: BE
Depends on: F2-BE-02

### Output
- ShareReceiverActivity (ACTION_SEND image/*+text/plain, ACTION_SEND_MULTIPLE)
- salin `content://` off-main-thread, `.part` lalu rename atomik
- deteksi source_type (GALLERY_SHARE, GALLERY_PICKER, PINTEREST, GENERIC_URL, DIRECT_IMAGE_LINK)
- batas 20 gambar/share, 50 MB/file; gagal dicatat FAILED

### Acceptance Criteria
- [x] Izin URI sementara tidak dipakai setelah activity selesai
- [x] Batas ukuran/jumlah ditegakkan, kegagalan tetap tercatat
- [x] configChanges agar copy tidak terputus saat rotasi
- [x] Unit test Kotlin 16 lulus
- [ ] Uji share manual di HP (ditunda)

## [F3-BE-02] resolve_external_media (Rust)
Status: DONE (host-only)
Owner: BE

### Output
- rust/src/domain/{url_policy, manifest, html, pipeline, tests}
- manifest default Pinterest/pin.it di-seed RegistryBootstrap

### Acceptance Criteria
- [x] extractors_manifest per-domain + fallback og:image + direct image link
- [x] og:image relatif di-resolve setelah redirect
- [x] Batas 25 MB gambar, 2 MB HTML, timeout 20s
- [x] Blokir localhost/private/link-local, kredensial URL, port tidak wajar
- [x] needs_login/blocked -> pesan FAILED jelas
- [x] cargo test 46 lulus, fmt+clippy -D warnings bersih

## [F3-BE-03] WorkManager background download
Status: DONE (host-only)
Owner: BE

### Output
- UrlImportWorker + backgroundImportMain + UrlImportRunner
- unique work url-import-download, constraint jaringan, exponential backoff

### Acceptance Criteria
- [x] Resume baris DOWNLOADING otomatis
- [x] MainActivity KEEP tidak menimpa pekerjaan aktif
- [x] Timeout engine = retry, bukan cancel
- [x] flutter build apk debug arm64 berhasil
- [ ] Uji resume saat proses dibunuh OS di HP (ditunda)

### Notes
- Build multi-ABI bisa kena 504 unduhan sqlite3 x64 dari GitHub; verifikasi pakai `--target-platform android-arm64`.
- Tidak ada perubahan docs/** dari BE.
