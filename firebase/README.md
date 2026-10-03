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

XP dan progres belajar tersimpan secara privat per akun pada
`profiles/{uid}/progress/current`, bukan pada direktori pemain. Leaderboard
masih memakai data demo.

## Progres akun dan logout

Publish `firebase/firestore.rules` terbaru sebelum menjalankan versi ini.
Rules lama belum mengizinkan subcollection progres, sehingga login akan
menampilkan pesan gagal memuat profil sampai rules diperbarui.

Setelah profil siap, aplikasi memuat progres dari server berdasarkan UID.
Akun yang belum memiliki progres mulai dari level 1 dan 0 XP. Akun lama
yang hanya memiliki profil juga mendapat progres awal tersebut; progres
demo dari versi sebelumnya belum pernah tersimpan dan tidak bisa dipulihkan.

Data yang disimpan: level akun, total XP, XP harian, streak, statistik sesi
selesai/berhasil, level latihan selesai, dan status/progres pelajaran.
Setiap 100 XP menaikkan level akun satu tingkat. Permainan menyimpan otomatis
setelah sesi selesai (termasuk sesi gagal untuk statistik); sesi soal yang
masih berlangsung tidak dilanjutkan di tengah soal setelah login ulang.
Reset progres juga disimpan untuk akun yang sedang login.

Logout menunggu antrean penyimpanan dan konfirmasi server sebelum sign-out.
Jika koneksi atau izin Firestore gagal, akun tetap login dan pengguna bisa
mencoba simpan/logout kembali. Login tidak mengganti data server yang gagal
dibaca dengan progres kosong. UI Home dan Profil menggunakan progres yang sama.

Uji online dengan dua akun terverifikasi: selesaikan latihan pada akun A,
catat XP dan level, logout, masuk akun B dan pastikan progresnya terpisah,
lalu masuk akun A lagi dan pastikan XP serta level latihan terbuka sama.
Uji logout setelah koneksi diputus: logout harus gagal sampai penyimpanan
berhasil setelah koneksi pulih. Uji akses dokumen progres akun lain dengan
Firestore Emulator/Rules Playground; akses tersebut harus ditolak.

Penyimpanan memakai snapshot akun dan bukan mekanisme anti-cheat atau
penggabungan progres dari dua perangkat yang bermain bersamaan.


## Permintaan pertemanan
Publish rules terbaru untuk collection friendships sebelum memakai Tambah teman. Dokumen pasangan unik menyimpan anggota, pengirim/penerima, nama pemain, status pending/accepted, dan waktu pembuatan. Penerima dapat menerima/menolak; pengirim dapat membatalkan. Setelah diterima, keduanya melihat teman yang sama. Hanya dua anggota yang bisa membaca hubungan ini. Tidak perlu composite index untuk query members arrayContains.
Uji dengan dua akun: cari Jovan, kirim permintaan, buka akun Jovan, terima permintaan, lalu pastikan keduanya muncul dalam daftar Temanmu. Data pertemanan tersimpan di Firestore dan tetap ada setelah app ditutup.

