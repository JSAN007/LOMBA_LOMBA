import 'package:cybernusa/components/practice/narrative_grading_panel.dart';
import 'package:cybernusa/core/theme/cyber_theme.dart';
import 'package:cybernusa/services/narrative_grader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestGrader implements NarrativeGrader {
  bool fail = false;
  @override
  Future<NarrativeGrade?> load(String questionId) async => null;
  @override
  Future<NarrativeGrade> grade(String questionId, String answer) async {
    if (fail) throw const GradingFailure('Saldo API belum tersedia.');
    return NarrativeGrade.fromJson({
      'score': 65,
      'accuracy': 20,
      'priorities': 15,
      'reasoning': 15,
      'verification': 15,
      'feedback': 'Jelaskan cara memverifikasi pemulihan.',
      'improvements': ['Tambahkan pemantauan.'],
      'answer': answer,
    });
  }
}

void main() {
  testWidgets(
    'Shows grading feedback, hides stale score after editing, and handles API failure',
    (tester) async {
      final grader = TestGrader();
      Future<void> mount(String answer) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: CyberTheme.dark,
            home: Scaffold(
              body: SingleChildScrollView(
                child: NarrativeGradingPanel(
                  questionId: 'case',
                  answer: answer,
                  grader: grader,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await mount('Saya memeriksa log.');
      await tester.tap(find.text('Nilai jawaban'));
      await tester.pumpAndSettle();
      expect(find.text('65/100'), findsOneWidget);
      expect(find.text('Tingkat kemampuan: Lanjutan'), findsOneWidget);
      expect(find.text('Ketepatan tindakan: 20/25'), findsOneWidget);
      expect(find.text('Verifikasi pemulihan: 15/25'), findsOneWidget);
      expect(
        find.text('Jelaskan cara memverifikasi pemulihan.'),
        findsOneWidget,
      );
      await mount('Jawaban terbaru.');
      expect(find.text('65/100'), findsNothing);
      grader.fail = true;
      await tester.tap(find.text('Nilai jawaban'));
      await tester.pumpAndSettle();
      expect(find.text('Saldo API belum tersedia.'), findsOneWidget);
      expect(find.text('65/100'), findsNothing);
    },
  );
}
