"use client";

import { useEffect, useState } from "react";

interface ScoreGaugeProps {
  score: number; // 0-100
  size?: number;
  strokeWidth?: number;
  label?: string;
}

export default function ScoreGauge({
  score,
  size = 160,
  strokeWidth = 10,
  label = "Risiko Siber",
}: ScoreGaugeProps) {
  const [animatedScore, setAnimatedScore] = useState(0);

  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  // We show 75% of circle (270 degrees)
  const arcLength = circumference * 0.75;
  const dashOffset = arcLength - (arcLength * animatedScore) / 100;

  // Determine color based on score (inverted: low score = green/safe)
  const getColor = (s: number) => {
    if (s <= 30) return { main: "var(--accent-green)", glow: "var(--glow-green)", text: "Aman" };
    if (s <= 60) return { main: "var(--accent-amber)", glow: "0 0 20px rgba(245,158,11,0.3)", text: "Waspada" };
    return { main: "var(--accent-red)", glow: "var(--glow-red)", text: "Berbahaya" };
  };

  const colorInfo = getColor(animatedScore);

  useEffect(() => {
    // Animate the score from 0 to target
    const duration = 1200;
    const startTime = Date.now();
    const startVal = animatedScore;
    const target = Math.min(100, Math.max(0, score));

    const animate = () => {
      const elapsed = Date.now() - startTime;
      const progress = Math.min(elapsed / duration, 1);
      // Ease out cubic
      const eased = 1 - Math.pow(1 - progress, 3);
      setAnimatedScore(Math.round(startVal + (target - startVal) * eased));

      if (progress < 1) {
        requestAnimationFrame(animate);
      }
    };

    requestAnimationFrame(animate);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [score]);

  return (
    <div className="flex flex-col items-center gap-1">
      <div className="relative" style={{ width: size, height: size }}>
        <svg
          width={size}
          height={size}
          viewBox={`0 0 ${size} ${size}`}
          className="transform -rotate-[225deg]"
        >
          {/* Background arc */}
          <circle
            cx={size / 2}
            cy={size / 2}
            r={radius}
            fill="none"
            stroke="rgba(100, 116, 139, 0.15)"
            strokeWidth={strokeWidth}
            strokeLinecap="round"
            strokeDasharray={`${arcLength} ${circumference}`}
          />
          {/* Foreground arc */}
          <circle
            cx={size / 2}
            cy={size / 2}
            r={radius}
            fill="none"
            stroke={colorInfo.main}
            strokeWidth={strokeWidth}
            strokeLinecap="round"
            strokeDasharray={`${arcLength} ${circumference}`}
            strokeDashoffset={dashOffset}
            style={{
              filter: `drop-shadow(${colorInfo.glow})`,
              transition: "stroke 0.5s ease",
            }}
          />
        </svg>

        {/* Center content */}
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <span
            className="text-4xl font-black tabular-nums"
            style={{ color: colorInfo.main }}
          >
            {animatedScore}
          </span>
          <span
            className="text-xs font-semibold px-2 py-0.5 rounded-full mt-0.5"
            style={{
              color: colorInfo.main,
              background: `${colorInfo.main}15`,
            }}
          >
            {colorInfo.text}
          </span>
        </div>
      </div>
      <p className="text-xs text-text-secondary font-medium -mt-3">{label}</p>
    </div>
  );
}
