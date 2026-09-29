"use client";

import { useNavigation } from "@/lib/store";

export default function LessonsPlaceholder() {
  const { navigate } = useNavigation();

  return (
    <div className="flex flex-col min-h-[calc(100dvh-72px)] px-5 pt-6 pb-4">
      <h1 className="text-xl font-bold text-text-primary mb-1">📚 Pelajaran</h1>
      <p className="text-sm text-text-secondary mb-6">
        Pilih topik untuk mulai belajar
      </p>

      <div className="flex flex-col gap-3 stagger-children">
        {[
          {
            id: "wa-scam",
            emoji: "📦",
            title: "Penipuan WA Kurir",
            desc: "Kenali modus pengiriman file APK berbahaya",
            difficulty: "Pemula",
            xp: 100,
            color: "var(--accent-green)",
          },
          {
            id: "qris-palsu",
            emoji: "💳",
            title: "QRIS Palsu",
            desc: "Pelajari cara membedakan QRIS asli dan palsu",
            difficulty: "Menengah",
            xp: 150,
            color: "var(--accent-amber)",
          },
          {
            id: "otp-scam",
            emoji: "🔑",
            title: "Modus OTP",
            desc: "Lindungi kode OTP-mu dari social engineering",
            difficulty: "Pemula",
            xp: 100,
            color: "var(--accent-cyan)",
          },
        ].map((lesson) => (
          <button
            key={lesson.id}
            onClick={() => navigate("lesson-detail", lesson.id)}
            className="glass rounded-2xl p-4 text-left flex items-center gap-4 transition-all duration-200 hover:border-cyan/20 active:scale-[0.98]"
          >
            <div
              className="w-12 h-12 rounded-xl flex items-center justify-center shrink-0 text-2xl"
              style={{ background: `${lesson.color}12` }}
            >
              {lesson.emoji}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-bold text-text-primary">{lesson.title}</p>
              <p className="text-[11px] text-text-muted truncate">{lesson.desc}</p>
              <div className="flex items-center gap-2 mt-1.5">
                <span
                  className="text-[10px] font-semibold px-2 py-0.5 rounded-full"
                  style={{ background: `${lesson.color}15`, color: lesson.color }}
                >
                  {lesson.difficulty}
                </span>
                <span className="text-[10px] text-text-muted">⚡ {lesson.xp} XP</span>
              </div>
            </div>
            <svg
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="var(--text-muted)"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            >
              <path d="M9 18l6-6-6-6" />
            </svg>
          </button>
        ))}
      </div>

      {/* Coming soon */}
      <div className="mt-6 glass rounded-2xl p-4 text-center">
        <p className="text-xs text-text-muted">
          🔒 Lebih banyak pelajaran segera hadir di update berikutnya!
        </p>
      </div>
    </div>
  );
}
