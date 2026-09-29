"use client";

import { useApp, useNavigation } from "@/lib/store";
import { PERSONA_MAP } from "@/lib/types";
import ScoreGauge from "@/components/ui/ScoreGauge";

export default function ProfilePage() {
  const { state, dispatch } = useApp();
  const { navigate } = useNavigation();
  const persona = state.persona ? PERSONA_MAP[state.persona] : null;

  return (
    <div className="flex flex-col min-h-[calc(100dvh-72px)] px-5 pt-6 pb-4">
      <h1 className="text-xl font-bold text-text-primary mb-6">👤 Profil</h1>

      <div className="stagger-children">
        {/* Profile Card */}
        <div className="glass rounded-3xl p-6 text-center mb-4 relative overflow-hidden">
          <div className="absolute -top-8 -right-8 w-32 h-32 rounded-full bg-purple/5 blur-[40px] pointer-events-none" />

          <div className="w-16 h-16 rounded-2xl gradient-cyber flex items-center justify-center mx-auto mb-3 text-3xl">
            {persona?.emoji || "👤"}
          </div>
          <h2 className="text-lg font-bold text-text-primary mb-0.5">
            {state.displayName || "Pengguna"}
          </h2>
          {persona && (
            <span
              className="inline-block text-xs font-semibold px-3 py-1 rounded-full"
              style={{ background: `${persona.color}15`, color: persona.color }}
            >
              {persona.label}
            </span>
          )}
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-3 gap-2 mb-4">
          {[
            { label: "Total XP", value: state.xp, icon: "⚡", color: "var(--accent-purple)" },
            { label: "Streak", value: state.streak, icon: "🔥", color: "var(--accent-amber)" },
            { label: "Level", value: state.level, icon: "🏆", color: "var(--accent-cyan)" },
          ].map((stat) => (
            <div key={stat.label} className="glass rounded-xl p-3 text-center">
              <span className="text-lg">{stat.icon}</span>
              <p className="text-lg font-black mt-0.5" style={{ color: stat.color }}>
                {stat.value}
              </p>
              <p className="text-[10px] text-text-muted font-medium">{stat.label}</p>
            </div>
          ))}
        </div>

        {/* Score */}
        <div className="glass rounded-2xl p-5 flex justify-center mb-4">
          <ScoreGauge score={state.cyberRiskScore} size={140} strokeWidth={8} />
        </div>

        {/* Reset button */}
        <button
          onClick={() => {
            if (confirm("Yakin mau reset semua data? Ini tidak bisa dibatalkan.")) {
              dispatch({ type: "RESET" });
              navigate("onboarding");
            }
          }}
          className="w-full glass rounded-xl p-3 text-center text-xs font-medium text-red hover:bg-red/5 transition-colors"
        >
          🗑️ Reset Semua Data
        </button>
      </div>
    </div>
  );
}
