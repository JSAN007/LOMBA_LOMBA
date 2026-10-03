import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/cyber_colors.dart';
import '../components/shell_navigation_bar.dart';
import '../widgets/responsive_layout_wrapper.dart';
import '../state/app_state.dart';
import '../state/app_state_provider.dart';
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

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer? _studyTimer;
  AppState? _state;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _studyTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_foreground) _state?.recordStudySecond();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = AppStateProvider.of(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    _studyTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
        bottomNavigationBar: ShellNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
