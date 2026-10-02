import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/cyber_colors.dart';
import '../../models/cyber_level.dart';
import '../../state/app_state_provider.dart';
import '../../widgets/responsive_layout_wrapper.dart';
import '../lesson/lesson_screen.dart';
import 'widgets/path_card.dart';
import 'widgets/progress_bar.dart';
import 'widgets/start_lesson_button.dart';
import 'widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor: CyberColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100), // Extra bottom padding for navbar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======= HEADER SECTION =======
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Row with avatar badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SecuriGo",
                                style: GoogleFonts.nunito(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: CyberColors.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Level ${state.level} · ${state.totalXp} XP",
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: CyberColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ======= STATS ROW (Streak, XP, Level) =======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    StatCard(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: CyberColors.accentOrange,
                      value: "${state.streakDays}",
                      label: "Streak",
                    ),
                    const SizedBox(width: 12),
                    StatCard(
                      icon: Icons.bolt_rounded,
                      iconColor: CyberColors.accentYellow,
                      value: "${state.totalXp}",
                      label: "XP",
                    ),
                    const SizedBox(width: 12),
                    StatCard(
                      icon: Icons.emoji_events_rounded,
                      iconColor: CyberColors.secondary,
                      value: "${state.level}",
                      label: "Level",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ======= DAILY GOAL & COURSE PROGRESS =======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CyberColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CyberColors.border, width: 1),
                  ),
                  child: Column(
                    children: [
                      // Daily Goal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Daily Goal",
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: CyberColors.textPrimary,
                            ),
                          ),
                          Text(
                            "${state.dailyXp}/${state.dailyGoalXp} min",
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.accentGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ProgressBar(
                        progress: state.dailyXp / state.dailyGoalXp,
                        color: CyberColors.accentGreen,
                        backgroundColor: CyberColors.accentGreen.withValues(alpha: 0.12),
                      ),
                      const SizedBox(height: 18),
                      // Course Progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Course Progress",
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: CyberColors.textPrimary,
                            ),
                          ),
                          Text(
                            "40%",
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ProgressBar(
                        progress: 0.4,
                        color: CyberColors.primary,
                        backgroundColor: CyberColors.primary.withValues(alpha: 0.12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ======= START LESSON BUTTON =======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StartLessonButton(
                  onPressed: () {
                    // Find first unlocked (non-completed) level
                    CyberLevel? target;
                    for (var level in state.levels) {
                      if (level.status == LevelStatus.unlocked) {
                        target = level;
                        break;
                      }
                    }
                    if (target != null) {
                      state.startLesson(target);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ResponsiveLayoutWrapper(
                            child: LessonScreen(),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 28),

              // ======= YOUR PATH SECTION =======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Your Path",
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: CyberColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Path lesson cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: state.levels.map((level) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PathCard(
                        level: level,
                        onTap: () {
                          if (level.status != LevelStatus.locked) {
                            state.startLesson(level);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ResponsiveLayoutWrapper(
                                  child: LessonScreen(),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: CyberColors.surfaceLight,
                                content: Row(
                                  children: [
                                    const Icon(Icons.lock_outline, color: CyberColors.secondary),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Selesaikan level sebelumnya untuk membuka '${level.title}'!",
                                        style: GoogleFonts.nunito(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Reset button
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton.icon(
                    onPressed: () {
                      AppStateProvider.of(context).resetProgress();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Progres disetel ulang untuk simulasi demo!",
                            style: GoogleFonts.nunito(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, color: CyberColors.textMuted, size: 16),
                    label: Text(
                      "Setel Ulang Progres Demo",
                      style: GoogleFonts.nunito(color: CyberColors.textMuted, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
