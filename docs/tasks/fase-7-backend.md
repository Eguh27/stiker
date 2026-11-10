# Fase 7 — Backend
Target: Android `StickerContentProvider`, `WhatsAppIntentChannel`, dan Dart Staging Exporter.
Kontrak terkait: docs/contracts/whatsapp-provider.md
Depends on: F4-BE-02

## [F7-BE-01] Android StickerContentProvider & Intent Channel
Status: DONE
Owner: BE
Depends on: F4-BE-02

### Konteks
Implementasi Kotlin untuk `StickerContentProvider` dan MethodChannel di `MainActivity.kt` sesuai spesifikasi WhatsApp.

### Output
- `android/app/src/main/kotlin/com/example/sticker_studio/provider/StickerContentProvider.kt`
- Tambahkan deklarasi provider di `AndroidManifest.xml`
- `android/app/src/main/kotlin/com/example/sticker_studio/whatsapp/WhatsAppIntentHandler.kt`
- Unit tests di `android/app/src/test/`

### Acceptance Criteria
- [ ] Provider merespons URI metadata, stickers, dan stickers_asset
- [ ] Intent `ENABLE_STICKER_PACK` dikirim dengan extras yang tepat
- [ ] Gradle test lulus

### Verification
```bash
./android/gradlew test
```

## [F7-BE-02] Staging Exporter Service di Dart
Status: DONE
Owner: BE
Depends on: F7-BE-01

### Konteks
Service di Dart untuk menyiapkan folder `wa_export_staging/<identifier>/` berisi WebP stiker, tray icon, dan file metadata JSON sebelum intent WhatsApp dijalankan.

### Output
- `lib/features/data/whatsapp/whatsapp_staging_exporter.dart`
- `lib/features/data/whatsapp/whatsapp_channel.dart`
- `test/data/whatsapp/whatsapp_staging_exporter_test.dart`

### Acceptance Criteria
- [ ] Membuat direktori staging dan menyalin/menulis tray icon & stiker WebP
- [ ] Menghasilkan metadata.json sesuai kontrak
- [ ] Validasi syarat WhatsApp sebelum ekspor (3..30 stiker, budget ukuran)

### Verification
```bash
flutter analyze
flutter test test/data/whatsapp
```
