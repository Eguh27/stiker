# Fase 0 — PM
Target: Contract freeze + handoff desain (tokens, screen-map, kontrak) selesai dan beku.
Kontrak terkait: docs/contracts/ffi.md, db-schema.md, manifests.md, stack.md
Desain terkait: design/tokens.json, design/screen-map.md
Depends on: -

## [F0-PM-01] Bekukan kontrak Fase 0
Status: IN_PROGRESS
Owner: PM
Depends on: -

### Konteks
Fase 0 belum punya kontrak apa pun, jadi Fase 1 tidak boleh jalan tanpa menebak signature/skema.

### Input
- TODO.md, AGENTS.md, design/figma-export/src/App.tsx, design/figma-export/src/index.css

### Output
- design/tokens.json, design/screen-map.md
- docs/contracts/ffi.md, db-schema.md, manifests.md, stack.md (v0.1.0 DRAFT)

### Acceptance Criteria
- [ ] tokens.json berisi light/dark + spacing/radius + batasan WhatsApp
- [ ] screen-map.md memetakan 10 view React ke Page/widget Flutter
- [ ] 4 signature FFI + 5 tabel DB + 4 manifest + versi stack tercatat

### Verification
```bash
test -f design/tokens.json && test -f design/screen-map.md
test -f docs/contracts/ffi.md
```

### Catatan / Blocker
- PNG design/screens/ masih kosong — FE pakai App.tsx + tokens.json sampai PNG dirender.
- stack.md wajib diverifikasi ulang via Context7 sebelum BE pakai library baru.
