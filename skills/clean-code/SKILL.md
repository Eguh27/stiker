---
name: clean-code
description: Aturan clean code untuk semua proyek. Pakai setiap kali menulis, mengubah, atau mereview kode, terutama saat membuat file baru, widget/komponen, memilih library, atau menamai variabel.
---

# Clean Code

1. **Batas ~100 baris.** File mendekati 100 baris -> pecah ke file baru (per tanggung jawab). Pengecualian: file hasil generate.
2. **Reuse dulu.** Sebelum menulis, cari widget/fungsi/komponen yang sudah ada. Pakai ulang atau perluas, jangan duplikasi.
3. **Minim komentar.** Kode harus menjelaskan dirinya lewat nama. Komentar hanya untuk "kenapa" yang tidak jelas (workaround, batasan WhatsApp), bukan "apa".
4. **Clean architecture.** Pisahkan `presentation` / `domain` / `data`. Domain tidak boleh bergantung ke framework/UI. Dependensi mengarah ke dalam, akses lewat interface.
5. **Penamaan jelas** untuk manusia dan bot: deskriptif, tanpa singkatan ambigu (`stickerPackList`, bukan `spl`). Fungsi = kata kerja (`encodeWebp`), boolean = `isX`/`hasX`.
6. **Cek tech dulu via MCP context7.** Sebelum memakai library/API/versi baru: `resolve-library-id` lalu `get-library-docs`. Catat versi di `docs/contracts/stack.md`.

## Checklist sebelum commit
- [ ] Tidak ada file > ~100 baris tanpa alasan
- [ ] Tidak ada kode duplikat yang bisa dipakai ulang
- [ ] Komentar seperlunya
- [ ] Layer arsitektur tidak bocor
- [ ] Nama mudah dipahami
- [ ] Library baru sudah dicek di context7
