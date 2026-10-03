import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cybernusa/state/app_state.dart';
import 'package:cybernusa/state/app_state_provider.dart';
import 'package:cybernusa/screens/lesson/lesson_screen.dart';

class QuestionBundle extends Fake implements AssetBundle {
  final pending = Completer<String>();
  @override
  Future<String> loadString(String key, {bool cache = true}) => pending.future;
}

void main() {
  final questions = File('assets/data/questions.json').readAsStringSync();
  testWidgets('Pushed level reads account state instead of global state', (
    tester,
  ) async {
    final bundle = QuestionBundle();
    final global = AppState(questionBundle: bundle);
    final account = AppState(questionBundle: bundle);
    await tester.pumpWidget(
      AppStateProvider(
        notifier: global,
        child: MaterialApp(
          home: AppStateProvider(
            notifier: account,
            child: Navigator(
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () {
                      account.startPractice(1);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LessonScreen()),
                      );
                    },
                    child: const Text('Open level 1'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    bundle.pending.complete(questions);
    await tester.pump();
    await tester.tap(find.text('Open level 1'));
    await tester.pumpAndSettle();
    expect(global.currentLessonQuestions, isEmpty);
    expect(account.currentLessonQuestions, isNotEmpty);
    expect(find.text(account.currentQuestion.question), findsOneWidget);
    expect(find.text('Soal belum tersedia'), findsNothing);
    await tester.ensureVisible(
      find.text(account.currentQuestion.options.first),
    );
    await tester.tap(find.text(account.currentQuestion.options.first));
    await tester.pumpAndSettle();
    expect(account.isAnswered, isTrue);
    await tester.ensureVisible(find.text(account.currentQuestion.explanation));
    expect(find.text(account.currentQuestion.explanation), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    global.dispose();
    account.dispose();
  });

  testWidgets('Starting level before assets load populates session afterward', (
    tester,
  ) async {
    final bundle = QuestionBundle();
    final state = AppState(questionBundle: bundle);
    state.startPractice(1);
    await tester.pumpWidget(
      AppStateProvider(
        notifier: state,
        child: const MaterialApp(home: LessonScreen()),
      ),
    );
    expect(find.text('Menyiapkan soal…'), findsOneWidget);
    bundle.pending.complete(questions);
    await tester.pumpAndSettle();
    expect(state.loadError, isNull);
    expect(state.currentLessonQuestions, isNotEmpty);
    expect(find.text(state.currentQuestion.question), findsOneWidget);
    final text = tester.widget<Text>(find.text(state.currentQuestion.question));
    expect(text.style?.color, isNot(Colors.white));
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
