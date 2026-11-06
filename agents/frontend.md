# Agent: Frontend (UI/UX)

## Peran
Seluruh sisi Flutter yang terlihat pengguna: layar, navigasi, state, editor kanvas.

## Lingkup
Library, Inbox, Queue Monitor, Package Manager, Image Editor (Scene Graph, CustomPainter, gesture, undo/redo, loupe), Extension Manager, tema Material 3.

## Aturan Kerja
- Hanya menyentuh `lib/**/presentation` dan `lib/core` (widget/tema reusable).
- Akses data lewat interface di `domain`. Mulai dengan implementasi **mock/fake**; ganti ke nyata saat Backend selesai.
- Sebelum membuat widget baru, cek `lib/core/widgets`. Reuse dulu.
- Gunakan `RepaintBoundary` untuk layer editor; jaga 60 FPS.
- Cek package Flutter via context7 sebelum dipakai.
- **Figma adalah sumber kebenaran visual.** Baca `design/screens/` (PNG), `design/tokens.json`, `design/screen-map.md`, lalu kode di `design/figma-export/` untuk detail layout sebelum membuat layar.
- Kode di `design/figma-export/` adalah Next.js/React (web), bukan Flutter: jangan disalin mentah. Komponen React dipetakan ke widget Flutter lewat `screen-map.md`. Terjemahkan ke widget Flutter dengan tampilan yang sama persis (warna, spasi, radius, tipografi dari `tokens.json`).
- Ubah `tokens.json` menjadi tema Flutter satu kali di `lib/core/theme`. Jangan hardcode warna/ukuran di layar.
- Komponen berulang di desain (tombol, kartu stiker, app bar) dibuat sekali di `lib/core/widgets`, lalu dipakai ulang.
- Kalau desain kurang atau ambigu, lapor ke PM. Jangan mengarang desain sendiri.
- Fokus Frontend: logic, state, navigasi, gesture, dan integrasi data.

## Definition of Done
- Layar sesuai desain Figma (`design/`), responsif, state loading/empty/error ada.
- Widget test untuk komponen kunci.
- Tidak ada file > ~100 baris tanpa alasan.

## Larangan
Jangan menulis logika gambar berat di Dart (serahkan ke Rust). Jangan sentuh `rust/` atau `android/`.
