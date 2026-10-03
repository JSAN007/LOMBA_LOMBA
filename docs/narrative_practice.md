# Practice naratif

Practice memiliki tab Pilihan ganda dan Naratif yang bisa digeser.
Pilihan ganda mempertahankan 50 level dan progres akun yang sudah ada.
Naratif menyediakan bacaan skenario, log, tugas penanganan, dan kolom jawaban
uraian. Tombol Simpan jawaban menulis draf ke
`profiles/{uid}/narrativeAnswers/{questionId}`. Jawaban dimuat lagi ketika
akun yang sama membuka skenario tersebut. Publish rules terbaru untuk
subcollection ini sebelum menyimpan. Tombol Nilai jawaban terhubung ke
backend NLP lokal. Lihat `backend/README.md` untuk konfigurasi
dan menjalankan backend. Hasil berupa skor 0–100 beserta feedback disimpan
di laptop backend, bukan Firestore. Hasil belum memberi XP.

## Asal data

`assets/data/narrative_questions.json` berisi 103 contoh `scenario` dari
`gen_val.jsonl` yang diberikan pengguna. Ini adalah contoh dataset validasi,
bukan hasil inference model dan bukan soal yang telah dinilai LLM.
Script importer menyusun cerita dari field log yang sudah tersedia dan
menambahkan variasi tugas penanganan DDoS, malware, dan akses tidak sah;
label serangan dalam log tidak ditebak dari fitur jaringan.

Reproduksi:

```powershell
python scripts/import_narrative_questions.py "C:\Users\jovan\Downloads\files (3)\gen_val.jsonl"
```

Dataset judge mencakup contoh baik dan contoh yang sengaja dirusak.
Dataset tersebut tidak digunakan langsung sebagai bank soal aplikasi.
Importer hanya membaca data JSON, tidak menjalankan script training
atau instruksi system/user yang tersimpan dalam dataset.

## Model dan penilaian

`train.py` melatih generator soal pilihan ganda dan judge kelayakan soal.
`run_pipeline.py` memakai judge untuk memberi skor correctness, clarity,
relevance dan verdict terhadap soal, bukan terhadap jawaban uraian pemain.
File JSONL adalah dataset; model hasil training, GGUF, dan URL API belum
disertakan. Penilaian sekarang memakai baseline TF-IDF dari referensi gen_train dan aturan rubrik. Bobot Qwen lama tidak tersedia. Baseline ini belum divalidasi dengan esai bernilai dari ahli; lihat backend/README.md untuk batasan dan reproduksi training.
