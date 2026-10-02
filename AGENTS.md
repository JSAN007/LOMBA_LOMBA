# Project Context
Aplikasi ini adalah project Flutter bernama [Cybernusa / sebutkan fungsi app lu]. 
Fokus utama adalah membuat UI/UX yang modern, clean, dan interaktif untuk mobile (iOS & Android).

# Tech Stack
- Flutter & Dart (versi terbaru dengan Null Safety penuh)
- State Management: [Isi sesuai yang lu pakai, misal: GetX / Riverpod / BLoC]

# UI/UX & Design Rules (STRICT - NO AI SLOP)
- JANGAN gunakan desain default Material yang kaku dan membosankan. Terapkan prinsip modern mobile design (seperti glassmorphism halus, bento grid, atau minimalis).
- WAJIB gunakan `Theme.of(context)` untuk manajemen warna dan text style. JANGAN hard-code warna (misal: `Color(0xFF...)`) berulang-ulang di dalam widget.
- Gunakan sudut membulat yang modern untuk Card dan Container (misal: `borderRadius: BorderRadius.circular(16)` atau `24`).
- Pastikan ada jarak (whitespace) yang lega antar elemen UI menggunakan `SizedBox` atau `Padding`. Jangan bikin UI yang terlalu berdempetan.
- Berikan animasi ringan atau transisi halus (`AnimatedContainer`, `Hero`, dll) untuk micro-interactions agar app terasa 'hidup'.

# Development Rules
- DILARANG KERAS memberikan respon dengan placeholder seperti `// ... existing code ...` atau `// tambahkan logika di sini`. Berikan kode utuh yang siap copas dan bisa jalan.
- HINDARI "Widget Hell" (nesting yang terlalu dalam). Jika sebuah widget tree sudah lebih dari 3 tingkat, paksa ekstrak menjadi Stateless/Stateful Widget terpisah di folder `lib/components` atau `lib/widgets`.
- Patuhi aturan linting dari `analysis_options.yaml`.