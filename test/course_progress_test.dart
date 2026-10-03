import 'dart:io';

import 'package:cybernusa/models/cyber_level.dart';
import 'package:cybernusa/services/progress_store.dart';
import 'package:cybernusa/state/app_state.dart';
import 'package:cybernusa/components/daily_goals_card.dart';
import 'package:cybernusa/core/theme/cyber_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Bundle extends Fake implements AssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      File('assets/data/questions.json').readAsStringSync();
}

class _Store implements ProgressStore {
  Map<String, dynamic>? data;
  @override
  Future<Map<String, dynamic>?> load() async => data;
  @override
  Future<void> save(Map<String, dynamic> progress) async => data = progress;
}

void main() {
  test('Five paths start at Practice levels 1, 11, 21, 31 and 41', () async {
    final state = AppState(questionBundle: _Bundle());
    await Future<void>.delayed(Duration.zero);
    expect(state.levels, hasLength(5));
    expect(state.courseProgress, 0);
    for (final path in state.levels) {
      state.startLesson(path);
      expect(state.currentSessionLevel, (path.id - 1) * 10 + 1);
      expect(state.currentLessonQuestions, isNotEmpty);
      final questions = state.currentLessonQuestions;
      state.startPractice(state.currentSessionLevel);
      expect(state.currentLessonQuestions, same(questions));
    }
    state.dispose();
  });

  test(
    'Resume derives all path and course progress from unique completions',
    () async {
      final store = _Store();
      final state = AppState(questionBundle: _Bundle(), progressStore: store);
      await state.loadProgress();
      state.completedPracticeLevels.addAll([
        ...List.generate(10, (i) => i + 1),
        11,
        41,
        42,
      ]);
      await state.saveProgress();
      // Compatible with currently deployed v1 Firestore rules.
      expect(store.data!['levels'], hasLength(4));
      final resumed = AppState(questionBundle: _Bundle(), progressStore: store);
      await resumed.loadProgress();
      expect(resumed.completedCourseLevels, 13);
      expect(resumed.courseProgress, 13 / 50);
      expect(resumed.levels.first.status, LevelStatus.completed);
      expect(resumed.levels.last.progress, .2);
      resumed.startLesson(resumed.levels.last);
      expect(resumed.currentSessionLevel, 43);
      resumed.resetProgress();
      expect(resumed.courseProgress, 0);
      expect(resumed.levels.every((path) => path.progress == 0), isTrue);
      state.dispose();
      resumed.dispose();
    },
  );

  test('Study time starts at zero and caps at 100 minutes per session', () {
    final state = AppState(questionBundle: _Bundle());
    expect(state.studyMinutes, 0);
    for (var i = 0; i < 60; i++) {
      state.recordStudySecond();
    }
    expect(state.studyMinutes, 1);
    for (var i = 0; i < 7000; i++) {
      state.recordStudySecond();
    }
    expect(state.studyMinutes, 100);
    expect(state.dailyGoalProgress, 1);
    final reopened = AppState(questionBundle: _Bundle());
    expect(reopened.studyMinutes, 0);
    state.dispose();
    reopened.dispose();
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets(
      'Daily Goals renders real counters on a narrow phone in $mode',
      (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final state = AppState(questionBundle: _Bundle());
        await tester.pumpWidget(
          MaterialApp(
            theme: CyberTheme.light,
            darkTheme: CyberTheme.dark,
            themeMode: mode,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: DailyGoalsCard(state: state),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('0 / 100 menit'), findsOneWidget);
        expect(find.text('0 / 50 level'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        state.dispose();
      },
    );
  }
}
