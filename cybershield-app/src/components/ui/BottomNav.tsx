"use client";

import { useNavigation } from "@/lib/store";
import type { AppView } from "@/lib/types";

interface NavItem {
  id: AppView;
  label: string;
  icon: (active: boolean) => React.ReactNode;
}

const navItems: NavItem[] = [
  {
    id: "dashboard",
    label: "Beranda",
    icon: (active) => (
      <svg
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke={active ? "var(--accent-cyan)" : "var(--text-muted)"}
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
        <polyline points="9 22 9 12 15 12 15 22" />
      </svg>
    ),
  },
  {
    id: "lessons",
    label: "Belajar",
    icon: (active) => (
      <svg
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke={active ? "var(--accent-cyan)" : "var(--text-muted)"}
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
        <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" />
        <line x1="9" y1="7" x2="16" y2="7" />
        <line x1="9" y1="11" x2="14" y2="11" />
      </svg>
    ),
  },
  {
    id: "simulator",
    label: "Simulasi",
    icon: (active) => (
      <svg
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke={active ? "var(--accent-cyan)" : "var(--text-muted)"}
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
        <path d="M9 12l2 2 4-4" />
      </svg>
    ),
  },
  {
    id: "profile",
    label: "Profil",
    icon: (active) => (
      <svg
        width="24"
        height="24"
        viewBox="0 0 24 24"
        fill="none"
        stroke={active ? "var(--accent-cyan)" : "var(--text-muted)"}
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      >
        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
        <circle cx="12" cy="7" r="4" />
      </svg>
    ),
  },
];

export default function BottomNav() {
  const { currentView, navigate } = useNavigation();

  // Don't show nav during onboarding or lesson detail
  if (currentView === "onboarding" || currentView === "lesson-detail") {
    return null;
  }

  return (
    <nav className="glass-strong sticky bottom-0 z-50 border-t border-cyan/10">
      <div className="flex items-center justify-around py-2 px-2">
        {navItems.map((item) => {
          const isActive = currentView === item.id;
          return (
            <button
              key={item.id}
              onClick={() => navigate(item.id)}
              className="flex flex-col items-center gap-0.5 py-1 px-4 rounded-xl transition-all duration-200 relative"
              style={{
                background: isActive ? "rgba(6, 214, 224, 0.08)" : "transparent",
              }}
            >
              {/* Active indicator dot */}
              {isActive && (
                <div className="absolute -top-1 w-5 h-0.5 rounded-full bg-cyan" />
              )}
              {item.icon(isActive)}
              <span
                className="text-[10px] font-semibold"
                style={{
                  color: isActive
                    ? "var(--accent-cyan)"
                    : "var(--text-muted)",
                }}
              >
                {item.label}
              </span>
            </button>
          );
        })}
      </div>
      {/* Safe area padding for mobile */}
      <div className="h-[env(safe-area-inset-bottom,0px)]" />
    </nav>
  );
}
