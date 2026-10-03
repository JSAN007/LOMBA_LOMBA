import 'package:flutter/material.dart';

import '../core/theme/cyber_colors.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/responsive_layout_wrapper.dart';
import 'package:cybernusa/screens/home/home_screen.dart';
import 'package:cybernusa/screens/leaderboard/leaderboard_screen.dart';
import 'package:cybernusa/screens/practice/practice_screen.dart';
import 'package:cybernusa/screens/profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final palette = context.cyber;

    return ResponsiveLayoutWrapper(
      child: Scaffold(
        backgroundColor: palette.background,
        extendBody: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) {
            final inAnim =
                Tween<Offset>(
                  begin: const Offset(0, 0.01),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );
            final fadeIn = CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
            );
            return FadeTransition(
              opacity: fadeIn,
              child: SlideTransition(position: inAnim, child: child),
            );
          },
          child: IndexedStack(
            key: ValueKey(_currentIndex),
            index: _currentIndex,
            children: [
              const HomeScreen(),
              const PracticeScreen(),
              const LeaderboardScreen(),
              const ProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: GlassNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
