import '../models/quiz_question.dart';

/// Bank soal deteksi phishing.
List<QuizQuestion> buildPhishingQuestions() => [
  QuizQuestion(
    id: 1,
    sender: "layanan@bank-cimb-aman.com",
    subject: "PENTING: Blokir Akun Sementara!",
    body: "Kepada Nasabah Yth,\n\nKami mendeteksi aktivitas mencurigakan pada akun Anda. Demi keamanan, akun Anda telah dinonaktifkan sementara.\n\nSilakan klik tautan di bawah ini untuk verifikasi ulang identitas Anda dalam 24 jam agar akun tidak ditutup permanen:\n👉 http://cimb-verifikasi-akun.online/login\n\nHormat kami,\nLayanan Pelanggan Bank CIMB",
    isPhishing: true,
    explanation: "Domain pengirim (bank-cimb-aman.com) dan link tujuan (cimb-verifikasi-akun.online) menggunakan domain tidak resmi (bukan domain asli bank). Bank resmi tidak akan pernah mengancam memblokir akun Anda dalam 24 jam via link eksternal tidak aman.",
    redFlags: ["Domain pengirim mencurigakan", "Menggunakan tautan HTTP tidak aman", "Tuntutan mendesak (ancaman 24 jam)"],
  ),
  QuizQuestion(
    id: 2,
    sender: "noreply@google.com",
    subject: "Notifikasi Keamanan: Login Baru di Windows",
    body: "Halo SiberNaut,\n\nAkun Google Anda baru saja digunakan untuk login di perangkat Windows baru (Jakarta, Indonesia).\n\nJika ini adalah Anda, tidak perlu ada tindakan lebih lanjut. Jika ini bukan Anda, silakan tinjau aktivitas akun Anda segera di menu keamanan akun Google Anda.\n\nTerima kasih,\nTim Akun Google",
    isPhishing: false,
    explanation: "Email ini aman. Domain pengirim (google.com) adalah resmi, dan email tersebut hanya memberikan notifikasi keamanan tanpa meminta Anda mengklik tautan verifikasi data pribadi yang mencurigakan.",
    redFlags: [],
  ),
  QuizQuestion(
    id: 3,
    sender: "admin-hrd@company-awards.xyz",
    subject: "Selamat! Anda Mendapatkan Bonus Kuartal dari HRD!",
    body: "Halo rekan-rekan,\n\nManajemen perusahaan ingin memberikan apresiasi atas kerja keras Anda selama kuartal ini. Anda terpilih sebagai salah satu penerima bonus tunai senilai Rp5.000.000.\n\nSegera unduh formulir penerimaan bonus di tautan berikut dan isi data rekening bank Anda:\n🔗 http://company-awards.xyz/download/form_bonus.xlsx.exe\n\nJangan beritahu rekan kerja lain demi kerahasiaan bonus Anda!",
    isPhishing: true,
    explanation: "Email ini phishing! Domain pengirim (company-awards.xyz) mencurigakan. File yang diminta diunduh berakhiran .xlsx.exe (file eksekusi berbahaya/malware menyamar sebagai dokumen Excel). HRD resmi tidak akan melarang Anda mengonfirmasi ke bagian keuangan.",
    redFlags: ["Ekstensi file ganda .xlsx.exe (Malware)", "Domain pengirim mencurigakan", "Iming-iming bonus bernilai besar"],
  ),
  QuizQuestion(
    id: 4,
    sender: "notifikasi@kurir-ekspedisi-cepat.xyz",
    subject: "Gagal Kirim: Paket Anda Tertahan di Bea Cukai",
    body: "Pelanggan yang terhormat,\n\nPaket dengan nomor resi JNE-993821-ID tidak dapat dikirimkan karena alamat tidak lengkap dan ada biaya kekurangan pajak bea cukai sebesar Rp15.000.\n\nSilakan selesaikan pembayaran dan perbarui alamat Anda segera melalui aplikasi pelacak paket di tautan berikut:\n🔗 http://kurir-ekspedisi-cepat.xyz/update-resi-pajak\n\nJika dalam 48 jam tidak ada pembayaran, paket akan dikembalikan ke pengirim.",
    isPhishing: true,
    explanation: "Email ini adalah phishing ekspedisi (Smishing/Phishing Paket). Domain pengirim (kurir-ekspedisi-cepat.xyz) bukan domain resmi JNE atau bea cukai. Ekspedisi resmi tidak meminta Anda mengunduh aplikasi mencurigakan atau membayar kekurangan pajak bea cukai melalui link eksternal tidak aman.",
    redFlags: ["Domain kurir palsu", "Meminta biaya tambahan via link tidak resmi", "Batas waktu 48 jam yang mendesak"],
  ),
];
