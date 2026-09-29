"use client";

import React, {
  createContext,
  useContext,
  useReducer,
  useEffect,
  useState,
  useCallback,
  type ReactNode,
  type Dispatch,
} from "react";
import type { UserState, Persona, SimulationResult, AppView } from "./types";

/* ==============================
   INITIAL STATE
   ============================== */

const INITIAL_STATE: UserState = {
  isOnboarded: false,
  persona: null,
  displayName: "",
  cyberRiskScore: 50,
  xp: 0,
  level: 1,
  streak: 0,
  lastActiveDate: null,
  completedLessons: [],
  simulationResults: [],
};

/* ==============================
   ACTIONS
   ============================== */

export type Action =
  | {
      type: "COMPLETE_ONBOARDING";
      payload: {
        persona: Persona;
        displayName: string;
        riskScore: number;
      };
    }
  | { type: "ADD_XP"; payload: number }
  | { type: "REDUCE_RISK"; payload: number }
  | { type: "COMPLETE_LESSON"; payload: string }
  | { type: "ADD_SIMULATION_RESULT"; payload: SimulationResult }
  | { type: "UPDATE_STREAK" }
  | { type: "RESET" };

/* ==============================
   HELPERS
   ============================== */

function calculateLevel(xp: number): number {
  // Every 200 XP = 1 level, minimum level 1
  return Math.floor(xp / 200) + 1;
}

function getTodayStr(): string {
  return new Date().toISOString().split("T")[0];
}

/* ==============================
   REDUCER
   ============================== */

function appReducer(state: UserState, action: Action): UserState {
  switch (action.type) {
    case "COMPLETE_ONBOARDING": {
      const today = getTodayStr();
      return {
        ...state,
        isOnboarded: true,
        persona: action.payload.persona,
        displayName: action.payload.displayName,
        cyberRiskScore: Math.min(100, Math.max(0, action.payload.riskScore)),
        streak: 1,
        lastActiveDate: today,
      };
    }

    case "ADD_XP": {
      const newXP = state.xp + action.payload;
      return {
        ...state,
        xp: newXP,
        level: calculateLevel(newXP),
      };
    }

    case "REDUCE_RISK": {
      return {
        ...state,
        cyberRiskScore: Math.max(0, state.cyberRiskScore - action.payload),
      };
    }

    case "COMPLETE_LESSON": {
      if (state.completedLessons.includes(action.payload)) return state;
      return {
        ...state,
        completedLessons: [...state.completedLessons, action.payload],
      };
    }

    case "ADD_SIMULATION_RESULT": {
      return {
        ...state,
        simulationResults: [...state.simulationResults, action.payload],
      };
    }

    case "UPDATE_STREAK": {
      const today = getTodayStr();
      if (state.lastActiveDate === today) return state;

      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayStr = yesterday.toISOString().split("T")[0];

      const newStreak =
        state.lastActiveDate === yesterdayStr ? state.streak + 1 : 1;

      return {
        ...state,
        streak: newStreak,
        lastActiveDate: today,
      };
    }

    case "RESET":
      return INITIAL_STATE;

    default:
      return state;
  }
}

/* ==============================
   STORAGE PERSISTENCE
   ============================== */

const STORAGE_KEY = "cybershield_user_state";

function loadState(): UserState {
  if (typeof window === "undefined") return INITIAL_STATE;
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (!stored) return INITIAL_STATE;
    return { ...INITIAL_STATE, ...JSON.parse(stored) };
  } catch {
    return INITIAL_STATE;
  }
}

function saveState(state: UserState) {
  if (typeof window === "undefined") return;
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch {
    // Storage full or unavailable — silently fail
  }
}

/* ==============================
   NAVIGATION CONTEXT
   ============================== */

interface NavigationContextType {
  currentView: AppView;
  lessonId: string | null;
  navigate: (view: AppView, lessonId?: string) => void;
}

const NavigationContext = createContext<NavigationContextType | null>(null);

export function useNavigation() {
  const ctx = useContext(NavigationContext);
  if (!ctx)
    throw new Error("useNavigation must be used within AppProvider");
  return ctx;
}

/* ==============================
   CONTEXT & PROVIDER
   ============================== */

interface AppContextType {
  state: UserState;
  dispatch: Dispatch<Action>;
}

const AppContext = createContext<AppContextType | null>(null);

export function useApp() {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error("useApp must be used within AppProvider");
  return ctx;
}

export function AppProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(appReducer, INITIAL_STATE, () =>
    loadState()
  );

  // Navigation state
  const [currentView, setCurrentView] = useState<AppView>(() =>
    loadState().isOnboarded ? "dashboard" : "onboarding"
  );
  const [lessonId, setLessonId] = useState<string | null>(null);

  const navigate = useCallback(
    (view: AppView, id?: string) => {
      setCurrentView(view);
      setLessonId(id ?? null);
    },
    []
  );

  // Persist state on every change
  useEffect(() => {
    saveState(state);
  }, [state]);

  // Update streak on mount
  useEffect(() => {
    if (state.isOnboarded) {
      dispatch({ type: "UPDATE_STREAK" });
    }
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <AppContext.Provider value={{ state, dispatch }}>
      <NavigationContext.Provider value={{ currentView, lessonId, navigate }}>
        {children}
      </NavigationContext.Provider>
    </AppContext.Provider>
  );
}
