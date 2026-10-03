import 'package:flutter/material.dart';

import '../core/theme/cyber_colors.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/responsive_layout_wrapper.dart';
import 'home/home_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import 'practice/practice_screen.dart';
import 'profile/profile_screen.dart';
import 'friends/friends_screen.dart';

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
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HomeScreen(),
            PracticeScreen(),
            LeaderboardScreen(),
            FriendsScreen(),
            ProfileScreen(),
          ],
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
