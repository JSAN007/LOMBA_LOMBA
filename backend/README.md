# Penilaian naratif lokal

Default backend adalah NLP lokal (TF-IDF + rubrik heuristik), tanpa API key atau panggilan OpenAI. Node.js 22+ diperlukan. Firebase tetap membutuhkan koneksi internet untuk login dan verifikasi token. Akun harus terverifikasi.

## Menjalankan

Dari direktori project, buka dua terminal:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/start_grading.ps1
```

Biarkan terminal backend terbuka. Pada terminal kedua:

```powershell
flutter run -d chrome --dart-define=GRADING_API_URL=http://127.0.0.1:8787
```

Login, buka Practice > Naratif, jawab lalu tekan **Nilai jawaban**. Restart backend setelah perubahan kode. Android Emulator memakai `http://10.0.2.2:8787`; perangkat fisik membutuhkan backend yang dapat diakses dari perangkat tersebut. Server default mendengar pada loopback laptop.

## Training dan batas model

Artifact `backend/models/local_nlp.json` dibuat dari 1.892 baris skenario gen_train.jsonl, yang hanya memiliki 9 referensi jawaban unik. Model mempelajari bobot TF-IDF kata dan potongan karakter. Ketepatan memakai kemiripan referensi; prioritas, alasan, verifikasi dan tindakan berbahaya memakai aturan eksplisit. Ini baseline latihan, bukan bobot Qwen hasil fine-tuning dan belum divalidasi terhadap penilaian manusia untuk esai. Jawaban kompleks, negasi, atau alternatif yang belum ada dapat salah dinilai dan perlu tinjauan manual.

Reproduksi artifact:

```powershell
node scripts/train_local_nlp.mjs "C:\Users\jovan\Downloads\files (3)\gen_train.jsonl"
```

Dataset judge lama menilai kualitas soal, bukan kemampuan pemain. Untuk penilai esai yang lebih andal, kumpulkan jawaban pemain dengan nilai/rubrik dari ahli dan evaluasi pada data terpisah.

## Hasil

Hasil mencakup skor 0–100, empat kemampuan 0–25 (ketepatan, prioritas, alasan, verifikasi), feedback dan saran. Tingkat berdasarkan satu jawaban: 0–19 Awam, 20–39 Dasar, 40–59 Menengah, 60–79 Lanjutan, 80–100 Pro. Ini tingkat latihan, bukan level akun atau sertifikasi. Hasil belum menambah XP.

Server mengambil soal dari katalog berdasarkan ID dan memverifikasi token Firebase. Draf tetap disimpan di Firestore dan membutuhkan rules terbaru. Hasil penilaian per akun/soal disimpan di `backend/.data/`, diabaikan Git; tersedia kembali selama data laptop backend tersebut tersedia. Perubahan jawaban menyembunyikan hasil lama. NLP lokal tidak memakai batas panggilan 20/jam; hanya satu penilaian aktif per akun.

## OpenAI opsional

```powershell
powershell -ExecutionPolicy Bypass -File scripts/start_grading.ps1 -Engine openai -Model gpt-4.1-mini
```

Mode ini meminta API key melalui prompt tersembunyi dan memerlukan saldo API. Batas 20 panggilan per akun/jam hanya berlaku di mode OpenAI. Key tidak dimasukkan ke Flutter atau Git.

## Verifikasi

```powershell
node --test backend/local_nlp.test.mjs backend/grader.test.mjs
flutter analyze
flutter test
```

Tes NLP adalah uji perilaku contoh, bukan ukuran akurasi pada jawaban pemain. Mode ini backend demo lokal; deployment bersama membutuhkan hosting HTTPS, APP_ORIGIN dan penyimpanan permanen.
