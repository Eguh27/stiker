# Fase 7 — Frontend
Target: Alur UI "Tambah ke WhatsApp" pada Pack Editor dan Pack List dengan status loading, dialog konfirmasi / pilihan WA biasa vs WA Business, dan snackbar error.
Kontrak terkait: docs/contracts/whatsapp-provider.md
Depends on: F4-FE-01, F6-INT-01

## [F7-FE-01] Tombol & Alur Tambah ke WhatsApp
Status: DONE
Owner: FE
Depends on: F4-FE-01

### Konteks
Pada `PackEditorPage`, tombol "Tambah ke WhatsApp" diaktifkan jika stiker berjumlah 3–30. Saat ditekan, sistem mengekspor aset staging, memeriksa instalasi WhatsApp / WA Business, dan mengirim Intent.

### Output
- Hubungkan tombol WhatsApp di `lib/features/packs/presentation/pack_editor_page.dart`
- Tampilkan loading overlay / indikator saat ekspor staging berlangsung
- Tampilkan opsi pilihan WhatsApp Reguler vs WhatsApp Business jika keduanya terpasang
- Notifikasi feedback (sukses / WhatsApp tidak terpasang)
- `test/features/packs/whatsapp_export_flow_test.dart`

### Acceptance Criteria
- [ ] Tombol disabled jika < 3 stiker, enabled jika 3–30 stiker
- [ ] Menampilkan pesan jika WhatsApp tidak terpasang di perangkat
- [ ] Memicu pemanggilan service ekspor dan intent channel
- [ ] Semua test widget lulus

### Verification
```bash
flutter analyze
flutter test test/features/packs/whatsapp_export_flow_test.dart
```
