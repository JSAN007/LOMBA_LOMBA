import 'package:cybernusa/state/app_state.dart';
import 'package:cybernusa/state/app_state_provider.dart';
import 'package:cybernusa/state/profile_controller.dart';
import 'package:cybernusa/core/theme/cyber_theme.dart';
import 'package:cybernusa/screens/main_shell.dart';
import 'package:cybernusa/screens/profile/profile_screen.dart';
import 'package:cybernusa/screens/friends/friends_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Teman and Profile open their own page without index errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final state = AppState();
    final profile = ProfileController();
    await tester.pumpWidget(
      AppStateProvider(
        notifier: state,
        child: ProfileProvider(
          notifier: profile,
          child: MaterialApp(theme: CyberTheme.light, home: const MainShell()),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(state.studySeconds, 2);
    for (final lifecycle in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(lifecycle);
    }
    await tester.pump(const Duration(seconds: 60));
    expect(state.studySeconds, 2);
    for (final lifecycle in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(lifecycle);
    }
    await tester.pump(const Duration(seconds: 58));
    expect(state.studyMinutes, 1);
    await tester.tap(find.text('Teman').last);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(FriendsScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Profile').last);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(FriendsScreen), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
    profile.dispose();
  });
}
