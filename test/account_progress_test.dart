import 'dart:async';
import 'dart:convert';

import 'package:cybernusa/models/cyber_level.dart';
import 'package:cybernusa/services/progress_store.dart';
import 'package:cybernusa/state/app_state.dart';
import 'package:cybernusa/state/app_state_provider.dart';
import 'package:cybernusa/core/theme/cyber_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class EmptyQuestions extends Fake implements AssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      jsonEncode({
        'levels': [
          {
            'level': 41,
            'questions': [
              {
                'id': 1,
                'question': 'Pilih tindakan aman',
                'options': ['Perbarui perangkat', 'Abaikan pembaruan'],
                'correctAnswerIndex': 0,
                'explanation': 'Pembaruan memperbaiki celah keamanan.',
              },
            ],
          },
        ],
      });
}

class MemoryProgressStore implements ProgressStore {
  Map<String, dynamic>? document;
  bool failWrites = false;
  Completer<void>? writeBarrier;
  final writes = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>?> load() async => document;

  @override
  Future<void> save(Map<String, dynamic> progress) async {
    await writeBarrier?.future;
    if (failWrites) throw StateError('offline');
    document = jsonDecode(jsonEncode(progress)) as Map<String, dynamic>;
    writes.add(document!);
  }
}

AppState account(MemoryProgressStore store) =>
    AppState(questionBundle: EmptyQuestions(), progressStore: store);

void main() {
  testWidgets(
    'Completing the final lesson automatically saves XP and unlocks',
    (tester) async {
      final store = MemoryProgressStore();
      final state = account(store);
      await state.loadProgress();
      state.startLesson(state.levels.last);
      state.answerQuestion(0);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: CyberTheme.dark,
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => state.nextQuestion(context),
                child: const Text('Terminer'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Terminer'));
      await tester.pumpAndSettle();
      expect(store.document!['totalXp'], 20);
      expect(store.document!['totalLessons'], 1);
      expect(store.document!['successfulLessons'], 1);
      final resumed = account(store);
      await resumed.loadProgress();
      expect(resumed.levels.last.status, LevelStatus.unlocked);
      expect(resumed.levels.last.progress, 0.1);
      expect(resumed.completedPracticeLevels, {41});
      expect(resumed.totalXp, 20);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
      resumed.dispose();
    },
  );

  test(
    'Account A resumes level 12 while account B has separate progress',
    () async {
      final storeA = MemoryProgressStore();
      final firstLogin = account(storeA);
      await firstLogin.loadProgress();
      firstLogin
        ..level = 12
        ..totalXp = 1140
        ..dailyXp = 80
        ..streakDays = 7
        ..totalLessons = 10
        ..successfulLessons = 8;
      firstLogin.completedPracticeLevels.addAll([1, 2, 11]);
      firstLogin.levels.first
        ..status = LevelStatus.completed
        ..progress = 1;
      var signedOut = false;
      await firstLogin.signOut(() async => signedOut = true);
      expect(signedOut, isTrue);
      firstLogin.dispose();

      final accountB = account(MemoryProgressStore());
      await accountB.loadProgress();
      expect(accountB.level, 1);
      expect(accountB.totalXp, 0);
      expect(accountB.completedPracticeLevels, isEmpty);
      expect(accountB.levels.first.status, LevelStatus.unlocked);

      final secondLogin = account(storeA);
      await secondLogin.loadProgress();
      expect(secondLogin.level, 12);
      expect(secondLogin.totalXp, 1140);
      expect(secondLogin.dailyXp, 80);
      expect(secondLogin.streakDays, 7);
      expect(secondLogin.totalLessons, 10);
      expect(secondLogin.successfulLessons, 8);
      expect(secondLogin.completedPracticeLevels, {1, 2, 11});
      expect(secondLogin.isPracticeUnlocked(12), isTrue);
      expect(secondLogin.levels.first.status, LevelStatus.unlocked);
      expect(secondLogin.levels.first.progress, 0.2);
      secondLogin.dispose();
      accountB.dispose();
    },
  );

  test(
    'Failed saving blocks logout and retry saves before signing out',
    () async {
      final store = MemoryProgressStore();
      final state = account(store);
      await state.loadProgress();
      state.level = 12;
      store.failWrites = true;
      var signedOut = false;
      Future<void> signOut() async {
        expect(store.document!['level'], 12);
        signedOut = true;
      }

      await expectLater(state.signOut(signOut), throwsStateError);
      expect(signedOut, isFalse);
      expect(state.isSigningOut, isFalse);
      expect(state.progressSaveError, isNotNull);
      store.failWrites = false;
      await state.signOut(signOut);
      expect(signedOut, isTrue);
      expect(state.progressSaveError, isNull);
      state.dispose();
    },
  );

  test(
    'Queued writes keep the latest progress and logout waits for them',
    () async {
      final store = MemoryProgressStore();
      final state = account(store);
      await state.loadProgress();
      store.writeBarrier = Completer<void>();
      state.level = 2;
      final saving = state.saveProgress();
      state.level = 12;
      var signedOut = false;
      final logout = state.signOut(() async => signedOut = true);
      await Future<void>.delayed(Duration.zero);
      expect(signedOut, isFalse);
      store.writeBarrier!.complete();
      await saving;
      await logout;
      expect(store.document!['level'], 12);
      expect(signedOut, isTrue);
      state.dispose();
    },
  );

  test('Reset is persisted for one account without changing another', () async {
    final storeA = MemoryProgressStore();
    final storeB = MemoryProgressStore();
    final a = account(storeA);
    final b = account(storeB);
    await a.loadProgress();
    await b.loadProgress();
    a.level = 12;
    b.level = 8;
    await a.saveProgress();
    await b.saveProgress();
    a.resetProgress();
    await a.saveProgress();
    final resumed = account(storeA);
    await resumed.loadProgress();
    expect(resumed.level, 1);
    expect(resumed.totalXp, 0);
    expect(storeB.document!['level'], 8);
    a.dispose();
    b.dispose();
    resumed.dispose();
  });

  test('An unreadable account is not replaced with fresh progress', () async {
    final store = MemoryProgressStore()..document = {'level': 12};
    final state = account(store);
    await expectLater(state.loadProgress(), throwsA(isA<TypeError>()));
    await expectLater(state.saveProgress(), throwsStateError);
    expect(store.writes, isEmpty);
    expect(store.document!['level'], 12);
    state.dispose();
  });
}
