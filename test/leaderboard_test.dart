import 'dart:io';

import 'package:cybernusa/models/leaderboard_entry.dart';
import 'package:cybernusa/components/leaderboard/leaderboard_self_rank.dart';
import 'package:cybernusa/components/leaderboard/leaderboard_podium.dart';
import 'package:cybernusa/screens/leaderboard/leaderboard_screen.dart';
import 'package:cybernusa/screens/lesson/lesson_screen.dart';
import 'package:cybernusa/core/theme/cyber_theme.dart';
import 'package:cybernusa/state/app_state.dart';
import 'package:cybernusa/state/app_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Questions extends Fake implements AssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      File('assets/data/questions.json').readAsStringSync();
}

LeaderboardEntry _user(int points) => LeaderboardEntry(
  userId: 'account',
  username: 'Rafi',
  avatarUrl: '',
  rank: 0,
  points: points,
  wins: 1,
  matches: 1,
  isCurrentUser: true,
);

void main() {
  testWidgets(
    'Finishing real lessons updates XP, rank and podium without restarting',
    (tester) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final state = AppState(questionBundle: _Questions())..totalXp = 0;
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            navigatorKey: navigator,
            theme: CyberTheme.light,
            home: const LeaderboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      LeaderboardEntry current() => tester
          .widget<LeaderboardSelfRank>(find.byType(LeaderboardSelfRank))
          .currentUser;
      expect(current().points, 0);
      expect(current().rank, 11);
      for (var level = 1; level <= 2; level++) {
        state.startPractice(level);
        navigator.currentState!.push(
          MaterialPageRoute<void>(builder: (_) => const LessonScreen()),
        );
        await tester.pumpAndSettle();
        final count = state.currentLessonQuestions.length;
        for (var i = 0; i < count; i++) {
          final answer = find.text(
            state.currentQuestion.options[state
                .currentQuestion
                .correctAnswerIndex],
          );
          await tester.ensureVisible(answer);
          await tester.pumpAndSettle();
          await tester.tap(answer);
          await tester.pumpAndSettle();
          final next = find.text(
            i == count - 1 ? 'Lihat hasil misi' : 'Lanjutkan',
          );
          await tester.ensureVisible(next);
          await tester.tap(next);
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Kembali ke Practice'));
        await tester.pumpAndSettle();
        expect(current().points, level * 100);
        expect(current().rank, level == 1 ? 6 : 1);
        expect(current().wins, level);
        expect(current().matches, level);
        expect(tester.takeException(), isNull);
      }
      final podium = tester.widget<LeaderboardPodium>(
        find.byType(LeaderboardPodium).first,
      );
      expect(podium.top3.any((entry) => entry.isCurrentUser), isTrue);
      // Swipe while the current user is on the podium: no duplicated avatar Hero.
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    },
  );
  test('Real user XP moves through fixed demo opponents', () {
    final opponents = LeaderboardEntry.demoOpponents(initialUserPoints: 0);
    expect(
      opponents.map((e) => e.points),
      orderedEquals(List.generate(10, (i) => (i + 1) * 20)),
    );
    for (final (points, rank) in [(0, 11), (100, 6), (200, 1)]) {
      final entries = LeaderboardEntry.rankEntries([
        ...opponents,
        _user(points),
      ]);
      final current = entries.singleWhere((entry) => entry.isCurrentUser);
      expect(current.points, points);
      expect(current.rank, rank);
      expect(entries, hasLength(11));
    }
  });

  test('Demo opponents stay close even for an existing high-XP account', () {
    final opponents = LeaderboardEntry.demoOpponents(initialUserPoints: 1260);
    expect(opponents.first.points, 1180);
    expect(opponents.last.points, 1360);
    final entries = LeaderboardEntry.rankEntries([...opponents, _user(1380)]);
    expect(entries.first.isCurrentUser, isTrue);
    expect(entries.first.rank, 1);
  });

  test('Equal scores share rank and input order cannot change tied order', () {
    final opponents = LeaderboardEntry.demoOpponents(initialUserPoints: 0);
    final entries = [...opponents, _user(100)];
    final ranked = LeaderboardEntry.rankEntries(entries);
    final reversed = LeaderboardEntry.rankEntries(entries.reversed.toList());
    expect(
      ranked.map((e) => e.userId),
      orderedEquals(reversed.map((e) => e.userId)),
    );
    expect(
      ranked.where((e) => e.points == 100).map((e) => e.rank),
      everyElement(6),
    );
  });
}
