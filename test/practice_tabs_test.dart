import 'dart:io';
import 'package:cybernusa/core/theme/cyber_theme.dart';
import 'package:cybernusa/models/narrative_question.dart';
import 'package:cybernusa/screens/lesson/lesson_screen.dart';
import 'package:cybernusa/screens/practice/practice_screen.dart';
import 'package:cybernusa/screens/practice/narrative_scenario_screen.dart';
import 'package:cybernusa/services/narrative_question_repository.dart';
import 'package:cybernusa/state/app_state.dart';
import 'package:cybernusa/state/app_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _PracticeBundle extends Fake implements AssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      File(key).readAsStringSync();
}

Future<AppState> mountPractice(WidgetTester tester) async {
  final state = AppState(questionBundle: _PracticeBundle());
  await tester.pumpWidget(
    AppStateProvider(
      notifier: state,
      child: MaterialApp(
        theme: CyberTheme.dark,
        home: PracticeScreen(
          narrativeRepository: NarrativeQuestionRepository(
            bundle: _PracticeBundle(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  addTearDown(state.dispose);
  return state;
}

void main() {
  test('Dataset examples load with unique IDs and supporting logs', () async {
    final questions = await NarrativeQuestionRepository(
      bundle: _PracticeBundle(),
    ).load();
    expect(questions.length, 103);
    expect(
      questions.every((q) => q.question.startsWith('Tangani kasus ')),
      isTrue,
    );
    expect(questions.map((q) => q.id).toSet().length, questions.length);
    expect(
      questions.every(
        (q) => q.scenario.isNotEmpty && q.log.contains('attack='),
      ),
      isTrue,
    );
  });

  testWidgets('Practice swipes between choice levels and narrative scenarios', (
    tester,
  ) async {
    await mountPractice(tester);
    expect(find.text('Level 1 · Awam'), findsOneWidget);
    expect(find.text('Level 2 · Awam'), findsOneWidget);
    await tester.drag(find.byType(TabBarView), const Offset(-650, 0));
    await tester.pumpAndSettle();
    expect(find.textContaining('Skenario 1 ·'), findsOneWidget);
    await tester.tap(find.textContaining('Skenario 1 ·'));
    await tester.pumpAndSettle();
    expect(find.byType(NarrativeScenarioScreen), findsOneWidget);
    expect(find.text('Log pendukung'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    final question = tester
        .widget<NarrativeScenarioScreen>(find.byType(NarrativeScenarioScreen))
        .question;
    expect(question, isA<NarrativeQuestion>());
    await tester.tap(find.text('Log pendukung'));
    await tester.pumpAndSettle();
    expect(find.text(question.log), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pilihan ganda'));
    await tester.pumpAndSettle();
    expect(find.text('Level 1 · Awam'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('The existing choice practice still starts the selected level', (
    tester,
  ) async {
    final state = await mountPractice(tester);
    await tester.tap(find.text('Level 1 · Awam'));
    await tester.pumpAndSettle();
    expect(state.activePracticeLevel, 1);
    expect(find.byType(LessonScreen), findsOneWidget);
    expect(state.currentLessonQuestions, isNotEmpty);
    expect(tester.takeException(), isNull);
  });
}
