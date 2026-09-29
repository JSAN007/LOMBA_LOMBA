"use client";

import { useState } from "react";
import { useApp, useNavigation } from "@/lib/store";
import { ONBOARDING_QUESTIONS } from "@/lib/quiz-data";
import type { Persona, QuizOption } from "@/lib/types";

export default function OnboardingQuiz() {
  const { dispatch } = useApp();
  const { navigate } = useNavigation();

  const [step, setStep] = useState<"welcome" | "quiz" | "result">("welcome");
  const [currentQ, setCurrentQ] = useState(0);
  const [answers, setAnswers] = useState<QuizOption[]>([]);
  const [selectedOption, setSelectedOption] = useState<string | null>(null);
  const [displayName, setDisplayName] = useState("");
  const [calculatedScore, setCalculatedScore] = useState(0);
  const [detectedPersona, setDetectedPersona] = useState<Persona>("mahasiswa");

  const totalQuestions = ONBOARDING_QUESTIONS.length;
  const progress = step === "quiz" ? ((currentQ + 1) / totalQuestions) * 100 : 0;

  const handleSelectOption = (option: QuizOption) => {
    setSelectedOption(option.value);

    // Auto-advance after short delay
    setTimeout(() => {
      const newAnswers = [...answers, option];
      setAnswers(newAnswers);
      setSelectedOption(null);

      if (currentQ + 1 < totalQuestions) {
        setCurrentQ((prev) => prev + 1);
      } else {
        // Calculate final results
        const totalRisk = newAnswers.reduce((sum, a) => sum + a.riskWeight, 0);
        // Base risk of 15, plus accumulated risk from answers, capped at 95
        const riskScore = Math.min(95, 15 + totalRisk);
        const persona =
          newAnswers.find((a) => a.persona)?.persona ?? "mahasiswa";

        setCalculatedScore(riskScore);
        setDetectedPersona(persona);
        setStep("result");
      }
    }, 400);
  };

  const handleFinish = () => {
    dispatch({
      type: "COMPLETE_ONBOARDING",
      payload: {
        persona: detectedPersona,
        displayName: displayName || "Pengguna",
        riskScore: calculatedScore,
      },
    });
    navigate("dashboard");
  };

  // ==================== WELCOME SCREEN ====================
  if (step === "welcome") {
    return (
      <div className="flex flex-col min-h-screen px-6 pt-16 pb-8 relative overflow-hidden">
        {/* Background decoration */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[300px] h-[300px] rounded-full bg-cyan/5 blur-[80px] pointer-events-none" />
        <div className="absolute bottom-20 right-0 w-[200px] h-[200px] rounded-full bg-purple/5 blur-[60px] pointer-events-none" />

        {/* Content */}
        <div className="flex-1 flex flex-col items-center justify-center text-center stagger-children">
          {/* Shield Logo */}
          <div className="w-24 h-24 rounded-3xl gradient-cyber flex items-center justify-center mb-6 animate-float shadow-lg shadow-cyan/20">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
              <path d="M9 12l2 2 4-4" />
            </svg>
          </div>

          <h1 className="text-3xl font-black gradient-text-cyber mb-2">
            CyberShield
          </h1>
          <p className="text-text-secondary text-sm leading-relaxed max-w-[280px] mb-2">
            Belajar keamanan siber dengan cara yang{" "}
            <span className="text-cyan font-semibold">seru</span> dan{" "}
            <span className="text-purple font-semibold">interaktif</span>
          </p>

          {/* Feature pills */}
          <div className="flex flex-wrap justify-center gap-2 mt-6 mb-8">
            {[
              { emoji: "🎯", text: "Profil Risiko Personal" },
              { emoji: "📱", text: "Simulasi Scam Nyata" },
              { emoji: "🏆", text: "Gamifikasi & XP" },
            ].map((f) => (
              <span
                key={f.text}
                className="glass text-xs font-medium px-3 py-1.5 rounded-full text-text-secondary"
              >
                {f.emoji} {f.text}
              </span>
            ))}
          </div>

          {/* Name input */}
          <div className="w-full max-w-[300px] mb-6">
            <label className="text-xs text-text-muted font-medium mb-2 block text-left">
              Nama panggilan kamu
            </label>
            <input
              type="text"
              value={displayName}
              onChange={(e) => setDisplayName(e.target.value)}
              placeholder="Contoh: Budi"
              maxLength={20}
              className="w-full bg-card border border-cyan/10 rounded-2xl px-4 py-3.5 text-sm text-text-primary placeholder:text-text-muted focus:outline-none focus:border-cyan/40 focus:ring-1 focus:ring-cyan/20 transition-all"
            />
          </div>
        </div>

        {/* CTA Button */}
        <button
          onClick={() => setStep("quiz")}
          className="btn-primary w-full text-base"
        >
          🚀 Mulai Profil Risiko
        </button>

        <p className="text-[11px] text-text-muted text-center mt-3">
          3 pertanyaan singkat • Kurang dari 1 menit
        </p>
      </div>
    );
  }

  // ==================== QUIZ SCREEN ====================
  if (step === "quiz") {
    const question = ONBOARDING_QUESTIONS[currentQ];

    return (
      <div className="flex flex-col min-h-screen px-6 pt-8 pb-8">
        {/* Progress bar */}
        <div className="flex items-center gap-3 mb-8">
          <button
            onClick={() => {
              if (currentQ > 0) {
                setCurrentQ((prev) => prev - 1);
                setAnswers((prev) => prev.slice(0, -1));
              } else {
                setStep("welcome");
              }
            }}
            className="text-text-muted hover:text-text-primary transition-colors"
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M15 18l-6-6 6-6" />
            </svg>
          </button>
          <div className="flex-1 h-2 bg-card rounded-full overflow-hidden">
            <div
              className="h-full rounded-full gradient-cyber transition-all duration-500 ease-out"
              style={{ width: `${progress}%` }}
            />
          </div>
          <span className="text-xs text-text-muted font-medium tabular-nums">
            {currentQ + 1}/{totalQuestions}
          </span>
        </div>

        {/* Question */}
        <div key={question.id} className="animate-fade-in-up">
          <div className="mb-8">
            <h2 className="text-xl font-bold text-text-primary leading-snug mb-2">
              {question.question}
            </h2>
            <p className="text-sm text-text-secondary">{question.subtitle}</p>
          </div>

          {/* Options */}
          <div className="flex flex-col gap-3">
            {question.options.map((option, idx) => {
              const isSelected = selectedOption === option.value;
              return (
                <button
                  key={option.value}
                  onClick={() => handleSelectOption(option)}
                  disabled={selectedOption !== null}
                  className="w-full text-left p-4 rounded-2xl border transition-all duration-200 flex items-center gap-3"
                  style={{
                    background: isSelected
                      ? "rgba(6, 214, 224, 0.12)"
                      : "var(--bg-card)",
                    borderColor: isSelected
                      ? "var(--accent-cyan)"
                      : "rgba(6, 214, 224, 0.06)",
                    transform: isSelected ? "scale(0.98)" : "scale(1)",
                    animationDelay: `${idx * 0.08}s`,
                  }}
                >
                  <span className="text-2xl w-10 h-10 rounded-xl bg-surface flex items-center justify-center shrink-0">
                    {option.emoji}
                  </span>
                  <span className="text-sm font-medium text-text-primary">
                    {option.label}
                  </span>
                  {isSelected && (
                    <svg
                      className="ml-auto shrink-0"
                      width="20"
                      height="20"
                      viewBox="0 0 24 24"
                      fill="var(--accent-cyan)"
                    >
                      <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z" />
                    </svg>
                  )}
                </button>
              );
            })}
          </div>
        </div>
      </div>
    );
  }

  // ==================== RESULT SCREEN ====================
  return (
    <div className="flex flex-col min-h-screen px-6 pt-12 pb-8 relative overflow-hidden">
      {/* Background effects */}
      <div className="absolute top-10 left-1/2 -translate-x-1/2 w-[250px] h-[250px] rounded-full bg-cyan/5 blur-[80px] pointer-events-none" />

      <div className="flex-1 flex flex-col items-center justify-center text-center animate-fade-in-scale">
        {/* Result emoji */}
        <div className="text-6xl mb-4 animate-float">
          {calculatedScore > 60 ? "⚠️" : calculatedScore > 30 ? "🟡" : "🟢"}
        </div>

        <h2 className="text-2xl font-black text-text-primary mb-1">
          Profil Risiko Kamu
        </h2>
        <p className="text-sm text-text-secondary mb-8">
          Berdasarkan jawaban yang kamu berikan
        </p>

        {/* Score display */}
        <div className="glass rounded-3xl p-8 w-full max-w-[300px] mb-6">
          <div className="relative w-32 h-32 mx-auto mb-4">
            <svg width="128" height="128" viewBox="0 0 128 128" className="-rotate-90">
              <circle
                cx="64"
                cy="64"
                r="56"
                fill="none"
                stroke="rgba(100,116,139,0.12)"
                strokeWidth="8"
              />
              <circle
                cx="64"
                cy="64"
                r="56"
                fill="none"
                stroke={
                  calculatedScore > 60
                    ? "var(--accent-red)"
                    : calculatedScore > 30
                    ? "var(--accent-amber)"
                    : "var(--accent-green)"
                }
                strokeWidth="8"
                strokeLinecap="round"
                strokeDasharray={`${(2 * Math.PI * 56 * calculatedScore) / 100} ${2 * Math.PI * 56}`}
                className="transition-all duration-1000"
              />
            </svg>
            <div className="absolute inset-0 flex flex-col items-center justify-center">
              <span
                className="text-3xl font-black"
                style={{
                  color:
                    calculatedScore > 60
                      ? "var(--accent-red)"
                      : calculatedScore > 30
                      ? "var(--accent-amber)"
                      : "var(--accent-green)",
                }}
              >
                {calculatedScore}
              </span>
              <span className="text-[10px] text-text-muted font-semibold">
                / 100
              </span>
            </div>
          </div>

          <p className="text-sm text-text-secondary leading-relaxed">
            {calculatedScore > 60
              ? "Kamu cukup rentan terhadap ancaman siber. Tapi tenang, CyberShield akan membantumu! 💪"
              : calculatedScore > 30
              ? "Kamu sudah cukup waspada, tapi masih ada ruang untuk belajar lebih banyak! 📚"
              : "Kamu sudah cukup aman! Tapi tetap harus up-to-date dengan ancaman terbaru. 🛡️"}
          </p>
        </div>

        {/* Persona badge */}
        <div className="glass rounded-2xl px-4 py-3 flex items-center gap-3 mb-8">
          <span className="text-2xl">
            {detectedPersona === "mahasiswa" && "🎓"}
            {detectedPersona === "karyawan" && "💼"}
            {detectedPersona === "umkm" && "🏪"}
            {detectedPersona === "pendamping_lansia" && "🤝"}
          </span>
          <div className="text-left">
            <p className="text-xs text-text-muted font-medium">Persona kamu</p>
            <p className="text-sm font-bold text-text-primary">
              {detectedPersona === "mahasiswa" && "Mahasiswa"}
              {detectedPersona === "karyawan" && "Karyawan"}
              {detectedPersona === "umkm" && "Pelaku UMKM"}
              {detectedPersona === "pendamping_lansia" && "Pendamping Lansia"}
            </p>
          </div>
        </div>
      </div>

      {/* CTA */}
      <button onClick={handleFinish} className="btn-primary w-full text-base">
        🛡️ Mulai Belajar Sekarang
      </button>
    </div>
  );
}
