import 'dart:async';
import 'package:cybernusa/models/learning_activity.dart';
import 'package:cybernusa/services/progress_store.dart';
import 'package:cybernusa/state/app_state.dart';
import 'package:cybernusa/state/app_state_provider.dart';
import 'package:cybernusa/core/theme/cyber_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'account_progress_test.dart' show MemoryProgressStore, EmptyQuestions;

class HistoryStore extends MemoryProgressStore implements ActivityStore {
  final history = <String, LearningActivity>{};
  bool failHistory = false;
  @override
  Future<List<LearningActivity>> loadActivities() async =>
      history.values.toList();
  @override
  Future<void> saveActivity(LearningActivity activity) async {
    if (failHistory) throw StateError('offline');
    history[activity.id] = LearningActivity.fromMap(
      activity.id,
      activity.toMap(),
    );
  }
}

void main() {
  testWidgets(
    'Real lesson history is retried without duplicates and restored on login',
    (tester) async {
      final store = HistoryStore();
      final state = AppState(
        progressStore: store,
        questionBundle: EmptyQuestions(),
      );
      await state.loadProgress();
      state.startPractice(41);
      state.answerQuestion(0);
      store.failHistory = true;
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: CyberTheme.light,
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => state.nextQuestion(context),
                child: const Text('Finish'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();
      expect(state.activities.length, 1);
      expect(state.activities.single.level, 41);
      expect(state.streakDays, 1);
      expect(state.progressSaveError, isNotNull);
      expect(store.history, isEmpty);
      store.failHistory = false;
      await state.saveProgress();
      await state.saveProgress();
      expect(store.history.length, 1);
      final resumed = AppState(
        progressStore: store,
        questionBundle: EmptyQuestions(),
      );
      await resumed.loadProgress();
      expect(resumed.activities.single.xp, 20);
      expect(resumed.streakDays, 1);
      resumed.resetProgress();
      await resumed.saveProgress();
      expect(store.history.length, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
      resumed.dispose();
    },
  );
  test(
    'Deletion drains queued writes and rejects new progress saves',
    () async {
      final store = HistoryStore();
      final state = AppState(
        progressStore: store,
        questionBundle: EmptyQuestions(),
      );
      await state.loadProgress();
      final baseline = store.writes.length;
      store.writeBarrier = Completer<void>();
      final saving = state.saveProgress();
      final preparing = state.prepareAccountDeletion();
      expect(state.accountDeletionStarted, true);
      await state.saveProgress();
      expect(store.writes.length, baseline);
      store.writeBarrier!.complete();
      await saving;
      await preparing;
      expect(store.writes.length, baseline + 1);
      state.resetProgress();
      await state.saveProgress();
      expect(store.writes.length, baseline + 1);
      state.dispose();
    },
  );
}
