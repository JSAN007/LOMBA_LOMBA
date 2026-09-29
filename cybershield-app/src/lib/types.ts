/* ==============================
   TYPE DEFINITIONS — CyberShield
   ============================== */

export type Persona = "mahasiswa" | "karyawan" | "umkm" | "pendamping_lansia";

export interface PersonaInfo {
  id: Persona;
  label: string;
  emoji: string;
  description: string;
  color: string;
}

export const PERSONA_MAP: Record<Persona, PersonaInfo> = {
  mahasiswa: {
    id: "mahasiswa",
    label: "Mahasiswa",
    emoji: "🎓",
    description: "Pelajar & Mahasiswa",
    color: "var(--accent-blue)",
  },
  karyawan: {
    id: "karyawan",
    label: "Karyawan",
    emoji: "💼",
    description: "Pekerja Kantoran",
    color: "var(--accent-cyan)",
  },
  umkm: {
    id: "umkm",
    label: "Pelaku UMKM",
    emoji: "🏪",
    description: "Pengusaha & UMKM",
    color: "var(--accent-amber)",
  },
  pendamping_lansia: {
    id: "pendamping_lansia",
    label: "Pendamping Lansia",
    emoji: "🤝",
    description: "Pendamping Keluarga Lansia",
    color: "var(--accent-purple)",
  },
};

export interface QuizQuestion {
  id: number;
  question: string;
  subtitle: string;
  options: QuizOption[];
}

export interface QuizOption {
  label: string;
  value: string;
  emoji: string;
  /** Risk weight added to score (higher = more at risk) */
  riskWeight: number;
  /** If this option determines the persona */
  persona?: Persona;
}

export interface UserState {
  isOnboarded: boolean;
  persona: Persona | null;
  displayName: string;
  cyberRiskScore: number; // 0-100 (0 = safe, 100 = very risky)
  xp: number;
  level: number;
  streak: number;
  lastActiveDate: string | null;
  completedLessons: string[];
  simulationResults: SimulationResult[];
}

export interface SimulationResult {
  id: string;
  scenarioId: string;
  passed: boolean;
  xpEarned: number;
  completedAt: string;
}

export interface Lesson {
  id: string;
  title: string;
  subtitle: string;
  emoji: string;
  category: string;
  difficulty: "beginner" | "intermediate" | "advanced";
  xpReward: number;
  riskReduction: number;
  steps: LessonStep[];
}

export interface LessonStep {
  id: number;
  type: "content" | "quiz";
  title?: string;
  content?: string;
  emoji?: string;
  // For quiz steps
  question?: string;
  options?: { label: string; isCorrect: boolean; explanation: string }[];
}

export type AppView =
  | "onboarding"
  | "dashboard"
  | "lessons"
  | "lesson-detail"
  | "simulator"
  | "profile";
