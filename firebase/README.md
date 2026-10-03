# Firebase SecuriGo

## Upgrade riwayat streak dan hapus akun

Publish **rules terbaru** dari `firebase/firestore.rules` di Firebase Console sebelum memakai upgrade ini. Rules menambahkan akses pemilik ke `profiles/{uid}/activities/{eventId}` serta izin menghapus progres dan profil sendiri dengan autentikasi ulang dalam 5 menit terakhir. Tidak ada akses ke data privat akun lain.

Riwayat mencatat setiap sesi Learn/Practice yang selesai atau gagal: waktu UTC (ditampilkan WIB), level, mode, jawaban benar, jumlah soal, status, dan XP yang benar-benar diterima. Sesi lama sebelum fitur ini tidak bisa direkonstruksi. Kalender mendukung hari/minggu/bulan dan pemilihan tanggal. Streak dihitung dari hari aktivitas yang berurutan, dengan toleransi hari ini belum belajar. Riwayat tetap disimpan walaupun reset progres; reset bukan penghapusan akun.

Hapus akun tersedia di Edit Profile. Pengguna harus memasukkan password dan mengonfirmasi tindakan permanen. Aplikasi reautentikasi, menunggu antrean save selesai, menghentikan write baru, menghapus seluruh aktivitas, hubungan pertemanan, progres, direktori pemain, dan profil, kemudian menghapus Firebase Auth user. Email dapat digunakan lagi hanya dengan registrasi baru. Firebase tidak otomatis menghapus subcollection saat dokumen induk dihapus, sehingga aplikasi membersihkannya secara eksplisit.

Penghapusan Firestore dan Firebase Auth bukan transaksi lintas layanan. Jika ada kegagalan, identitas dipertahankan untuk retry dan layar meminta pengguna menuntaskan penghapusan; sebagian data bisa sudah terhapus. Jangan tutup aplikasi saat penghapusan berlangsung. Tidak ada password yang disimpan atau dicatat.

Verifikasi online dengan **akun uji**, bukan akun utama: selesaikan sesi, logout/login, buka kalender dan pastikan riwayat sama; hapus akun dengan password salah (data harus utuh), kemudian password benar. Pastikan dokumen profil/progres/aktivitas/direktori dan pertemanan terkait hilang, login lama gagal, dan registrasi ulang email yang sama menghasilkan UID baru dengan 0 XP. Uji Rules Playground: akun B tidak boleh membaca/menghapus aktivitas atau profil A. Tes lokal tidak menggantikan verifikasi Firebase online.

Referensi: [Firebase reauthentication dan delete user](https://firebase.google.com/docs/auth/flutter/manage-users), [penghapusan dokumen dan subcollection](https://firebase.google.com/docs/firestore/manage-data/delete-data).

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

Jawaban uraian Practice Naratif disimpan sebagai draf privat pada
`profiles/{uid}/narrativeAnswers/{questionId}` lewat tombol Simpan jawaban.
Publish rules terbaru agar subcollection tersebut dapat dibaca/ditulis
pemilik akun. Draf dimuat kembali ketika akun membuka skenario yang sama;
penilaian NLP menggunakan backend lokal (lihat backend/README.md); XP naratif belum aktif.

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
