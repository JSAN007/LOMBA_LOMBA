# Firebase SecuriGo

Aplikasi memakai Firebase Authentication untuk akun, `profiles/{uid}` untuk profil privat, dan `players/{uid}` untuk pencarian nama pemain. Email dan password tidak disalin ke direktori pemain.

## Aktifkan halaman Teman

1. Buka Firebase Console project `lomba-b1608` > Firestore Database > Rules.
2. Gabungkan/pasang isi `firebase/firestore.rules`, lalu Publish. Jika ada collection lain yang sudah digunakan, pertahankan rules collection tersebut. Jangan memakai aturan `allow read, write: if true`.
3. Stop aplikasi lalu jalankan ulang. Akun yang sudah verifikasi email akan menulis direktori namanya saat login. Akun lama perlu login lagi setelah rules baru dipasang. Pencarian juga mencoba menyinkronkan akun yang sedang login; ini tidak menyinkronkan profil akun lain. Jika mencari Jovan dari akun lain, login Jovan sekali agar direktori Jovan terbentuk. Tidak ada migrasi seluruh Firebase Auth users dari aplikasi client.
4. Buka tab Teman dan cari minimal 2 karakter dari awal nama akun lain. Pencarian tidak membedakan huruf besar/kecil dan menampilkan maksimal 20 hasil. Contoh: `jo` menemukan `Jovan`; pencarian bukan berdasarkan email atau potongan tengah nama.

Direktori hanya memuat `displayName` dan `searchName`. Pemilik akun hanya dapat menulis nama yang sesuai profil privatnya. Akun terverifikasi lain dapat mencari direktori ini; profil privat tetap hanya dapat diakses pemiliknya. Pemain yang ditemukan dapat dikirimi permintaan. Pertemanan tersimpan setelah penerima menerima permintaan.

## Konfigurasi akun

Project ini sudah memakai `lib/firebase_options.dart` dari FlutterFire di `lib/main.dart`. Jalankan `flutterfire configure` lagi bila menambah platform/project Firebase. Aktifkan Authentication > Email/Password, buat Firestore, dan pasang rules sebelum menguji akun. App ID harus sesuai platform yang dijalankan. Jangan memasukkan service-account/private key ke aplikasi.

`AccountService.initialize` juga mendukung konfigurasi `--dart-define` bila Firebase belum diinisialisasi; konfigurasi ini tidak diperlukan ketika `main.dart` sudah memakai FlutterFire. `firebase/config.local.json` diabaikan Git.

## Pemeriksaan online

Gunakan dua akun terverifikasi. Setelah rules dipasang, login ulang keduanya, pastikan dokumen `players/{uid}` terbentuk, cari awalan nama akun lain, dan pastikan akun sendiri muncul dengan label Kamu. Uji pencarian tanpa hasil, koneksi terputus, dan akses profil privat akun lain yang harus ditolak. Pencarian menggunakan indeks tunggal bawaan `searchName`; jangan mengecualikan field tersebut dari indexing.

XP, progres latihan, dan leaderboard masih data lokal/demo. Data tersebut tidak ditulis dalam direktori pemain.


## Permintaan pertemanan
Publish rules terbaru untuk collection friendships sebelum memakai Tambah teman. Dokumen pasangan unik menyimpan anggota, pengirim/penerima, nama pemain, status pending/accepted, dan waktu pembuatan. Penerima dapat menerima/menolak; pengirim dapat membatalkan. Setelah diterima, keduanya melihat teman yang sama. Hanya dua anggota yang bisa membaca hubungan ini. Tidak perlu composite index untuk query members arrayContains.
Uji dengan dua akun: cari Jovan, kirim permintaan, buka akun Jovan, terima permintaan, lalu pastikan keduanya muncul dalam daftar Temanmu. Data pertemanan tersimpan di Firestore dan tetap ada setelah app ditutup.

