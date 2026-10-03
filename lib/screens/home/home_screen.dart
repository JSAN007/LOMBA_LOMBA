import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/motion/app_motion.dart';
import '../../core/theme/cyber_colors.dart';
import '../../components/daily_goals_card.dart';
import '../../components/activity_history_sheet.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/count_up_text.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/pop_in.dart';
import '../../core/widgets/pressable_scale.dart';
import '../../core/widgets/skeleton_to_content.dart';
import '../../models/cyber_level.dart';
import '../../state/app_state.dart';
import '../../state/app_state_provider.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/responsive_layout_wrapper.dart';
import '../lesson/lesson_screen.dart';
import 'widgets/path_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _introController;
  bool _isIntroLoading = true;
  bool _introStarted = false;
  Timer? _introTimer;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: AppMotion.introTotal,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // MediaQuery is not readable from initState, so the intro decision waits
    // for the first dependency pass.
    if (_introStarted) return;
    _introStarted = true;

    if (AppMotion.reduceAnimations(context)) {
      _isIntroLoading = false;
      _introController.value = 1.0;
      return;
    }

    // Hold the skeleton for the intro minimum, then run the entrance timeline.
    // The timer is cancelled on dispose so it cannot outlive the tree.
    _introTimer = Timer(AppMotion.introSkeletonMin, _beginIntro);
    _introController.forward(from: 0.0);
  }

  void _beginIntro() {
    if (!mounted) return;
    setState(() {
      _isIntroLoading = false;
    });
    _introController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _introTimer?.cancel();
    _introTimer = null;
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final palette = context.cyber;

    final content = _buildContent(context, state, palette);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: SkeletonToContent(
          isLoading: _isIntroLoading,
          skeleton: _buildSkeleton(context, palette),
          content: content,
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context, CyberPalette palette) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeletonText(width: 120, height: 28),
                        const SizedBox(height: 10),
                        AppSkeletonText(width: 160, height: 13),
                      ],
                    ),
                    const AppSkeletonCircle(size: 40),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(child: AppSkeletonCard(height: 80)),
                const SizedBox(width: 12),
                Expanded(child: AppSkeletonCard(height: 80)),
                const SizedBox(width: 12),
                Expanded(child: AppSkeletonCard(height: 80)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AppSkeletonCard(height: 180),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AppSkeletonText(width: 100, height: 22),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppSkeletonCard(height: 80),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppState state,
    CyberPalette palette,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom:
            kBottomNavigationBarHeight +
            MediaQuery.of(context).padding.bottom +
            16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            index: 0,
            delay: const Duration(milliseconds: 0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                color: palette.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Siap naik level, ${state.username}?",
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: palette.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "BELAJAR KECIL, KEKUATAN BESAR",
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                color: palette.textMuted,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Level ${state.level} � ${state.totalXp} XP",
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: palette.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopIn(
                        delay: const Duration(milliseconds: 200),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                CyberColors.primary,
                                CyberColors.secondary,
                              ],
                            ),
                            border: Border.all(
                              color: palette.background,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              state.username.isNotEmpty
                                  ? state.username[0].toUpperCase()
                                  : 'S',
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: palette.onAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeSlideIn(
            index: 1,
            delay: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => showActivityHistory(context, state),
                      child: _StatCardAnimated(
                        icon: Icons.local_fire_department_rounded,
                        iconColor: CyberColors.accentOrange,
                        value: state.streakDays.toDouble(),
                        label: "Streak ↗",
                        tintColor: CyberColors.accentOrange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCardAnimated(
                      icon: Icons.bolt_rounded,
                      iconColor: CyberColors.accentYellow,
                      value: state.totalXp.toDouble(),
                      label: "XP",
                      tintColor: CyberColors.accentYellow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCardAnimated(
                      icon: Icons.emoji_events_rounded,
                      iconColor: CyberColors.secondary,
                      value: state.level.toDouble(),
                      label: "Level",
                      tintColor: CyberColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          FadeSlideIn(
            index: 2,
            delay: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: DailyGoalsCard(state: state),
            ),
          ),
          const SizedBox(height: 28),

          FadeSlideIn(
            index: 3,
            delay: const Duration(milliseconds: 800),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Your Path",
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: state.levels.map((level) {
                final idx = state.levels.indexOf(level);
                return FadeSlideIn(
                  index: 4 + idx,
                  delay: const Duration(milliseconds: 900),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PressableScale(
                      onTap: () {
                        if (level.status != LevelStatus.locked) {
                          state.startLesson(level);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ResponsiveLayoutWrapper(
                                    child: LessonScreen(),
                                  ),
                            ),
                          );
                        } else {
                          showAppSnackBar(
                            context,
                            "Selesaikan level sebelumnya untuk membuka '${level.title}'!",
                            icon: Icons.lock_outline_rounded,
                          );
                        }
                      },
                      child: PathCard(level: level),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatCardAnimated extends StatelessWidget {
  const _StatCardAnimated({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.tintColor,
  });

  final IconData icon;
  final Color iconColor;
  final double value;
  final String label;
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.cyber;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tintColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tintColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          CountUpText(
            value: value,
            formatter: CountUpFormatters.integer,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: palette.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
