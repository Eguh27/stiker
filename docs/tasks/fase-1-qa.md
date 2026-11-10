# Fase 1 — QA (ditangani PM, bukan agent ke-3)
Target: Regresi fondasi Fase 1 host-only (HP fisik ditunda sampai project setengah).
Kontrak terkait: docs/contracts/*.md
Depends on: F1-FE-01, F1-FE-02, F1-BE-01, F1-BE-04
Mode: 2 agent saja (FE+BE). PM verifikasi manual, tidak spawn QA agent.

## [F1-QA-01] Regresi host-only
Status: DONE (PASS host-only, HP ditunda)
Owner: PM
Depends on: F1-FE-02, F1-BE-04

### Skenario (host-only sementara, Chromium boleh untuk FE)
- [x] `flutter analyze` + `flutter test` hijau
- [x] 4 tab shell berpindah di Chromium; tema dark/light tidak pecah
- [x] DB buat 5 tabel; file app_data/ dibuat first-run
- [x] FFI mati tidak blok UI (gagal dengan error, bukan freeze)

### Verification
```bash
flutter analyze
flutter test
cargo test
flutter devices && adb devices
```

### Catatan
- HP fisik adalah virtual device. Jangan pakai Linux desktop/Wayland sebagai bukti uji. Jika HP tidak terdeteksi, status BLOCKED + sertakan output devices.
