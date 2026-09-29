"use client";

import { useApp, useNavigation } from "@/lib/store";
import { PERSONA_MAP } from "@/lib/types";
import ScoreGauge from "@/components/ui/ScoreGauge";

export default function Dashboard() {
  const { state } = useApp();
  const { navigate } = useNavigation();

  const persona = state.persona ? PERSONA_MAP[state.persona] : null;
  const levelProgress = (state.xp % 200) / 200;
  const xpToNext = 200 - (state.xp % 200);

  return (
    <div className="flex flex-col pb-4 min-h-[calc(100dvh-72px)]">
      {/* ==================== HEADER ==================== */}
      <header className="px-5 pt-6 pb-4">
        <div className="flex items-center justify-between mb-1">
          <div>
            <p className="text-xs text-text-muted font-medium">Selamat datang 👋</p>
            <h1 className="text-xl font-bold text-text-primary">
              {state.displayName || "Pengguna"}
            </h1>
          </div>

          {/* Streak & XP badges */}
          <div className="flex items-center gap-2">
            {/* Streak */}
            <div className="glass rounded-xl px-3 py-1.5 flex items-center gap-1.5">
              <span className={`text-base ${state.streak > 0 ? "animate-flame" : ""}`}>
                🔥
              </span>
              <span className="text-sm font-bold text-amber">{state.streak}</span>
            </div>

            {/* XP */}
            <div className="glass rounded-xl px-3 py-1.5 flex items-center gap-1.5">
              <span className="text-base">⚡</span>
              <span className="text-sm font-bold text-purple">{state.xp}</span>
            </div>
          </div>
        </div>
      </header>

      {/* ==================== MAIN CONTENT ==================== */}
      <div className="flex-1 px-5 stagger-children">
        {/* Persona + Score Card */}
        <div className="glass rounded-3xl p-5 mb-4 relative overflow-hidden">
          {/* Decorative gradient blob */}
          <div className="absolute -top-10 -right-10 w-40 h-40 rounded-full bg-cyan/5 blur-[40px] pointer-events-none" />

          <div className="flex items-center gap-5">
            {/* Score Gauge */}
            <ScoreGauge score={state.cyberRiskScore} size={130} strokeWidth={8} />

            {/* Info */}
            <div className="flex-1 min-w-0">
              {/* Persona badge */}
              {persona && (
                <div
                  className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold mb-3"
                  style={{
                    background: `${persona.color}15`,
                    color: persona.color,
                  }}
                >
                  <span>{persona.emoji}</span>
                  {persona.label}
                </div>
              )}

              {/* Level */}
              <div className="mb-2">
                <div className="flex items-center justify-between mb-1">
                  <span className="text-xs text-text-muted font-medium">
                    Level {state.level}
                  </span>
                  <span className="text-[10px] text-text-muted tabular-nums">
                    {xpToNext} XP lagi
                  </span>
                </div>
                <div className="h-1.5 bg-surface rounded-full overflow-hidden">
                  <div
                    className="h-full rounded-full gradient-cyber transition-all duration-700 ease-out"
                    style={{ width: `${levelProgress * 100}%` }}
                  />
                </div>
              </div>

              {/* Stats row */}
              <div className="flex items-center gap-4 text-xs text-text-secondary">
                <span>📚 {state.completedLessons.length} pelajaran</span>
                <span>🎯 {state.simulationResults.filter((s) => s.passed).length} simulasi</span>
              </div>
            </div>
          </div>
        </div>

        {/* ==================== QUICK ACTIONS ==================== */}
        <div className="grid grid-cols-2 gap-3 mb-4">
          {/* Start Learning */}
          <button
            onClick={() => navigate("lessons")}
            className="group relative glass rounded-2xl p-4 text-left transition-all duration-200 hover:border-cyan/20 active:scale-[0.98] overflow-hidden"
          >
            <div className="absolute -bottom-4 -right-4 w-20 h-20 rounded-full bg-cyan/5 blur-[20px] pointer-events-none group-hover:bg-cyan/10 transition-colors" />
            <div className="w-10 h-10 rounded-xl bg-cyan/10 flex items-center justify-center mb-3">
              <span className="text-xl">📚</span>
            </div>
            <p className="text-sm font-bold text-text-primary mb-0.5">Mulai Belajar</p>
            <p className="text-[11px] text-text-muted">3 pelajaran tersedia</p>
          </button>

          {/* Scam Simulator */}
          <button
            onClick={() => navigate("simulator")}
            className="group relative glass rounded-2xl p-4 text-left transition-all duration-200 hover:border-purple/20 active:scale-[0.98] overflow-hidden"
          >
            <div className="absolute -bottom-4 -right-4 w-20 h-20 rounded-full bg-purple/5 blur-[20px] pointer-events-none group-hover:bg-purple/10 transition-colors" />
            <div className="w-10 h-10 rounded-xl bg-purple/10 flex items-center justify-center mb-3">
              <span className="text-xl">🛡️</span>
            </div>
            <p className="text-sm font-bold text-text-primary mb-0.5">Simulasi Scam</p>
            <p className="text-[11px] text-text-muted">Uji ketahananmu</p>
          </button>
        </div>

        {/* ==================== DAILY TIPS ==================== */}
        <div className="glass rounded-2xl p-4 mb-4 animate-shimmer">
          <div className="flex items-start gap-3">
            <span className="text-2xl">💡</span>
            <div>
              <p className="text-xs font-bold text-cyan mb-1">Tips Hari Ini</p>
              <p className="text-xs text-text-secondary leading-relaxed">
                Jangan pernah download file <span className="text-red font-semibold">.apk</span> dari
                chat WhatsApp, meskipun dikirim oleh orang yang kamu kenal. Akun
                mereka mungkin telah diretas!
              </p>
            </div>
          </div>
        </div>

        {/* ==================== THREAT LANDSCAPE ==================== */}
        <div className="mb-4">
          <h3 className="text-sm font-bold text-text-primary mb-3 px-1">
            🚨 Ancaman Terkini di Indonesia
          </h3>
          <div className="flex flex-col gap-2">
            {[
              {
                emoji: "📦",
                title: "Modus Kurir Paket",
                desc: 'Kirim file APK "foto paket"',
                severity: "high",
              },
              {
                emoji: "💳",
                title: "QRIS Palsu",
                desc: "Kode QR ditempel di atas yang asli",
                severity: "medium",
              },
              {
                emoji: "🔑",
                title: "Pencurian OTP",
                desc: "Minta kode OTP via telepon",
                severity: "high",
              },
            ].map((threat) => (
              <div
                key={threat.title}
                className="glass rounded-xl p-3 flex items-center gap-3"
              >
                <span className="text-xl w-9 h-9 rounded-lg bg-surface flex items-center justify-center shrink-0">
                  {threat.emoji}
                </span>
                <div className="flex-1 min-w-0">
                  <p className="text-xs font-semibold text-text-primary">
                    {threat.title}
                  </p>
                  <p className="text-[11px] text-text-muted truncate">
                    {threat.desc}
                  </p>
                </div>
                <span
                  className="text-[10px] font-bold px-2 py-0.5 rounded-full shrink-0"
                  style={{
                    background:
                      threat.severity === "high"
                        ? "rgba(239,68,68,0.12)"
                        : "rgba(245,158,11,0.12)",
                    color:
                      threat.severity === "high"
                        ? "var(--accent-red)"
                        : "var(--accent-amber)",
                  }}
                >
                  {threat.severity === "high" ? "Tinggi" : "Sedang"}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
