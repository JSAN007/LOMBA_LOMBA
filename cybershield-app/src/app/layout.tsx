import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "CyberShield — Jaga Dunia Digital Kamu",
  description:
    "Belajar keamanan siber dengan cara yang seru dan interaktif. Simulasi scam lokal, pelajaran mikro, dan profil risiko personal.",
  keywords: [
    "cybersecurity",
    "keamanan siber",
    "edukasi",
    "scam",
    "phishing",
    "Indonesia",
  ],
  authors: [{ name: "Team CyberShield — HackNusa 2026" }],
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  themeColor: "#050a18",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="id" className="h-full antialiased">
      <body className="min-h-full flex flex-col items-center bg-[#020617]">
        {/* Mobile shell — centered on desktop, full screen on mobile */}
        <div className="mobile-shell">{children}</div>
      </body>
    </html>
  );
}
