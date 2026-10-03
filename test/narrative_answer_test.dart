import 'dart:async';
import 'package:cybernusa/components/practice/narrative_answer_form.dart';
import 'package:cybernusa/core/theme/cyber_theme.dart';
import 'package:cybernusa/services/narrative_answer_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryAnswers implements NarrativeAnswerStore {
  final answers = <String, String>{};
  bool failReads = false;
  bool failWrites = false;
  Completer<void>? readBarrier;

  @override
  Future<String?> load(String questionId) async {
    await readBarrier?.future;
    if (failReads) throw StateError('offline');
    return answers[questionId];
  }

  @override
  Future<void> save(String questionId, String answer) async {
    if (failWrites) throw StateError('offline');
    answers[questionId] = answer;
  }
}

Future<void> _mountForm(WidgetTester tester, _MemoryAnswers store) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    MaterialApp(
      theme: CyberTheme.dark,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: NarrativeAnswerForm(questionId: 'case-a', store: store),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _saveAnswer(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Simpan jawaban');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('An empty answer is rejected without writing a draft', (
    tester,
  ) async {
    final store = _MemoryAnswers();
    await _mountForm(tester, store);
    await _saveAnswer(tester);
    expect(
      find.text('Tulis langkah penangananmu terlebih dahulu.'),
      findsOneWidget,
    );
    expect(store.answers, isEmpty);
  });

  testWidgets(
    'Saved answer reopens for the same account and stays separate from B',
    (tester) async {
      final accountA = _MemoryAnswers();
      final accountB = _MemoryAnswers();
      await _mountForm(tester, accountA);
      const answer =
          'Saya periksa log, tentukan tindakan mitigasi, lalu verifikasi pemulihan layanan.';
      await tester.enterText(find.byType(TextField), answer);
      await _saveAnswer(tester);
      expect(accountA.answers['case-a'], answer);
      expect(
        find.text('Draf jawaban tersimpan di akun'),
        findsOneWidget,
      );
      await _mountForm(tester, accountB);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await _mountForm(tester, accountA);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        answer,
      );
      await tester.enterText(
        find.byType(TextField),
        '$answer Saya juga memantau trafik.',
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Draf jawaban tersimpan di akun'),
        findsNothing,
      );
    },
  );

  testWidgets('Failed save keeps the answer editable and never claims success', (
    tester,
  ) async {
    final store = _MemoryAnswers()..failWrites = true;
    await _mountForm(tester, store);
    const answer =
        'Saya memeriksa aktivitas akun dan membatasi akses yang mencurigakan.';
    await tester.enterText(find.byType(TextField), answer);
    await _saveAnswer(tester);
    expect(store.answers, isEmpty);
    expect(
      find.text('Jawaban belum tersimpan. Periksa koneksi dan coba lagi.'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      answer,
    );
    expect(
      find.text('Draf jawaban tersimpan di akun'),
      findsNothing,
    );
    store.failWrites = false;
    await _saveAnswer(tester);
    expect(store.answers['case-a'], answer);
  });

  testWidgets(
    'A failed read cannot overwrite an existing answer with an empty draft',
    (tester) async {
      final store = _MemoryAnswers()
        ..answers['case-a'] = 'Jawaban akun yang sudah tersimpan.'
        ..failReads = true;
      await _mountForm(tester, store);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
      await tester.enterText(
        find.byType(TextField),
        'Rencana penanganan baru saya.',
      );
      expect(store.answers['case-a'], 'Jawaban akun yang sudah tersimpan.');
      store.failReads = false;
      await tester.ensureVisible(find.text('Muat ulang jawaban'));
      await tester.tap(find.text('Muat ulang jawaban'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Rencana penanganan baru saya.',
      );
      expect(find.text('Lihat jawaban yang sudah tersimpan'), findsOneWidget);
      await _saveAnswer(tester);
      expect(store.answers['case-a'], 'Rencana penanganan baru saya.');
    },
  );
  testWidgets('Typing during loading survives a late server response', (
    tester,
  ) async {
    final store = _MemoryAnswers()
      ..answers['case-a'] = 'Jawaban lama.'
      ..readBarrier = Completer<void>();
    await _mountForm(tester, store);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
    await tester.enterText(
      find.byType(TextField),
      'Jawaban yang sedang diketik.',
    );
    store.readBarrier!.complete();
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Jawaban yang sedang diketik.',
    );
    expect(store.answers['case-a'], 'Jawaban lama.');
    await _saveAnswer(tester);
    expect(store.answers['case-a'], 'Jawaban yang sedang diketik.');
  });
}

