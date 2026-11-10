# Fase 7 — Integrasi
Target: Hubungkan UI Pack Editor dengan Staging Exporter & WhatsApp Channel, uji end-to-end flow.
Kontrak terkait: docs/contracts/whatsapp-provider.md
Depends on: F7-FE-01, F7-BE-01, F7-BE-02

## [F7-INT-01] End-to-End WhatsApp Export Flow
Status: DONE
Owner: FE + BE
Depends on: F7-FE-01, F7-BE-01, F7-BE-02

### Konteks
Mengintegrasikan exporter dan intent channel ke UI `PackEditorPage`.

### Output
- Wiring di provider Flutter
- Build APK debug & verification

### Acceptance Criteria
- [ ] Tombol Tambah ke WhatsApp memicu staging export dan intent
- [ ] Menampilkan pesan error atau sukses sesuai hasil ekspor
- [ ] Seluruh test suite Flutter, Rust, dan Kotlin lulus

### Verification
```bash
flutter analyze
flutter test
cargo test --manifest-path rust/Cargo.toml
./android/gradlew test
flutter build apk --debug
```
