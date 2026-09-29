"use client";

import { AppProvider, useNavigation } from "@/lib/store";
import BottomNav from "@/components/ui/BottomNav";
import OnboardingQuiz from "@/components/onboarding/OnboardingQuiz";
import Dashboard from "@/components/dashboard/Dashboard";
import LessonsPage from "@/components/lessons/LessonsPage";
import SimulatorPage from "@/components/simulator/SimulatorPage";
import ProfilePage from "@/components/profile/ProfilePage";

function AppContent() {
  const { currentView } = useNavigation();

  return (
    <div className="flex flex-col h-full">
      <div className="flex-1 overflow-y-auto">
        {currentView === "onboarding" && <OnboardingQuiz />}
        {currentView === "dashboard" && <Dashboard />}
        {currentView === "lessons" && <LessonsPage />}
        {currentView === "lesson-detail" && <LessonsPage />}
        {currentView === "simulator" && <SimulatorPage />}
        {currentView === "profile" && <ProfilePage />}
      </div>
      <BottomNav />
    </div>
  );
}

export default function Home() {
  return (
    <AppProvider>
      <AppContent />
    </AppProvider>
  );
}
