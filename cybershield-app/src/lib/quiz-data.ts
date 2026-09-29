import type { QuizQuestion } from "./types";

export const ONBOARDING_QUESTIONS: QuizQuestion[] = [
  {
    id: 1,
    question: "Apa peran digital kamu sehari-hari?",
    subtitle: "Ini membantu kami menyesuaikan pelajaran untukmu",
    options: [
      {
        label: "Pelajar / Mahasiswa",
        value: "mahasiswa",
        emoji: "🎓",
        riskWeight: 0,
        persona: "mahasiswa",
      },
      {
        label: "Karyawan / Pekerja Kantoran",
        value: "karyawan",
        emoji: "💼",
        riskWeight: 0,
        persona: "karyawan",
      },
      {
        label: "Pelaku UMKM / Pengusaha",
        value: "umkm",
        emoji: "🏪",
        riskWeight: 0,
        persona: "umkm",
      },
      {
        label: "Pendamping Keluarga Lansia",
        value: "pendamping_lansia",
        emoji: "🤝",
        riskWeight: 0,
        persona: "pendamping_lansia",
      },
    ],
  },
  {
    id: 2,
    question: "Seberapa sering kamu klik link dari pesan WhatsApp?",
    subtitle: "Jawab jujur ya — tidak ada jawaban yang salah! 😊",
    options: [
      {
        label: "Sering, tanpa cek dulu",
        value: "often_no_check",
        emoji: "😰",
        riskWeight: 30,
      },
      {
        label: "Kadang-kadang, tergantung siapa yang kirim",
        value: "sometimes",
        emoji: "🤔",
        riskWeight: 18,
      },
      {
        label: "Jarang, saya biasanya cek dulu",
        value: "rarely",
        emoji: "🧐",
        riskWeight: 8,
      },
      {
        label: "Tidak pernah, saya selalu hati-hati",
        value: "never",
        emoji: "🛡️",
        riskWeight: 2,
      },
    ],
  },
  {
    id: 3,
    question: "Apakah kamu pernah membagikan kode OTP ke orang lain?",
    subtitle: "OTP = One-Time Password yang dikirim via SMS / WhatsApp",
    options: [
      {
        label: "Ya, pernah beberapa kali",
        value: "yes_multiple",
        emoji: "🚨",
        riskWeight: 35,
      },
      {
        label: "Pernah sekali, tapi tidak lagi",
        value: "yes_once",
        emoji: "😅",
        riskWeight: 20,
      },
      {
        label: "Tidak pernah, tapi tidak tahu itu berbahaya",
        value: "no_unaware",
        emoji: "🤷",
        riskWeight: 12,
      },
      {
        label: "Tidak pernah, saya tahu itu berbahaya",
        value: "no_aware",
        emoji: "✅",
        riskWeight: 3,
      },
    ],
  },
];
