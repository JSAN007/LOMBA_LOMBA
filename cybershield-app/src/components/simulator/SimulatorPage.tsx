"use client";

import { useNavigation } from "@/lib/store";

export default function SimulatorPlaceholder() {
  const { navigate } = useNavigation();

  return (
    <div className="flex flex-col min-h-[calc(100dvh-72px)] px-5 pt-6 pb-4">
      <h1 className="text-xl font-bold text-text-primary mb-1">🛡️ Simulasi Scam</h1>
      <p className="text-sm text-text-secondary mb-6">
        Latih instingmu melawan penipuan digital
      </p>

      <div className="stagger-children">
        {/* WhatsApp Phishing Sim Card */}
        <button
          onClick={() => navigate("lesson-detail", "wa-phishing-sim")}
          className="w-full glass rounded-3xl p-5 text-left relative overflow-hidden transition-all duration-200 hover:border-green-dim/30 active:scale-[0.98] mb-4"
        >
          <div className="absolute -top-6 -right-6 w-28 h-28 rounded-full bg-green/5 blur-[30px] pointer-events-none" />

          <div className="flex items-center gap-2 mb-3">
            <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-green/10 text-green">
              POPULER
            </span>
            <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-red/10 text-red">
              BARU
            </span>
          </div>

          <div className="flex items-center gap-4">
            <div className="w-14 h-14 rounded-2xl bg-green/10 flex items-center justify-center shrink-0">
              <span className="text-3xl">📱</span>
            </div>
            <div className="flex-1">
              <p className="text-base font-bold text-text-primary mb-0.5">
                WhatsApp Phishing
              </p>
              <p className="text-xs text-text-muted leading-relaxed">
                Simulasi chat kurir yang mengirim file APK berbahaya. Bisakah kamu mengenalinya?
              </p>
              <div className="flex items-center gap-3 mt-2">
                <span className="text-[10px] font-semibold text-purple">
                  🏆 +50 XP
                </span>
                <span className="text-[10px] text-text-muted">⏱️ 2 menit</span>
              </div>
            </div>
          </div>
        </button>

        {/* Locked sims */}
        {[
          { emoji: "💳", title: "QRIS Palsu Scan", desc: "Simulasi scan QR code berbahaya" },
          { emoji: "📞", title: "Telepon Social Engineering", desc: "Simulasi telepon penipuan" },
        ].map((sim) => (
          <div
            key={sim.title}
            className="glass rounded-2xl p-4 flex items-center gap-4 opacity-50 mb-3"
          >
            <div className="w-12 h-12 rounded-xl bg-surface flex items-center justify-center shrink-0 text-2xl">
              {sim.emoji}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-bold text-text-primary">{sim.title}</p>
              <p className="text-[11px] text-text-muted">{sim.desc}</p>
            </div>
            <span className="text-lg">🔒</span>
          </div>
        ))}

        <div className="mt-4 text-center">
          <p className="text-xs text-text-muted">
            Selesaikan pelajaran untuk membuka simulasi lainnya
          </p>
        </div>
      </div>
    </div>
  );
}
