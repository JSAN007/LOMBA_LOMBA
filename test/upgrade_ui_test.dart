import 'dart:async';
import 'package:cybernusa/components/activity_history_sheet.dart';
import 'package:cybernusa/components/delete_account_section.dart';
import 'package:cybernusa/components/practice_header.dart';
import 'package:cybernusa/core/theme/cyber_theme.dart';
import 'package:cybernusa/state/app_state.dart';
import 'package:cybernusa/state/app_state_provider.dart';
import 'package:cybernusa/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'account_progress_test.dart' show EmptyQuestions;

Future<void> capturePreview(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('CAPTURE_UI_PREVIEWS')) return;
  await expectLater(
    find.byType(Scaffold).first,
    matchesGoldenFile('../artifacts/previews/$name.png'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  for (final dark in [false, true]) {
    testWidgets('Activity history changes periods at 320px, dark=$dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final state = AppState(questionBundle: EmptyQuestions());
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? CyberTheme.dark : CyberTheme.light,
          home: Scaffold(body: ActivityHistorySheet(state: state)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Jejak belajarmu'), findsOneWidget);
      await capturePreview(tester, 'streak_${dark ? 'dark' : 'light'}');
      expect(tester.takeException(), isNull);
      final currentTitle = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .toList();
      await tester.tap(find.byTooltip('Periode sebelumnya'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<Text>(find.byType(Text))
            .map((text) => text.data)
            .toList(),
        isNot(currentTitle),
      );
      await tester.tap(find.text('Minggu'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ActivityCalendar>(find.byType(ActivityCalendar))
            .days
            .length,
        7,
      );
      await tester.tap(find.text('Hari'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ActivityCalendar>(find.byType(ActivityCalendar))
            .days
            .length,
        1,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });
    testWidgets(
      'Practice header path shortcuts and progress at 320px, dark=$dark',
      (tester) async {
        tester.view.physicalSize = const Size(320, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        int? started;
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? CyberTheme.dark : CyberTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: PracticeHeader(
                    completed: 12,
                    onStartPath: (level) => started = level,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('12/50 selesai'), findsOneWidget);
        await capturePreview(tester, 'practice_${dark ? 'dark' : 'light'}');
        await tester.tap(find.widgetWithText(ActionChip, 'Pro'));
        await tester.pumpAndSettle();
        expect(started, 41);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('Learn streak tile opens its expandable history', (tester) async {
    final state = AppState(questionBundle: EmptyQuestions());
    await tester.pumpWidget(
      AppStateProvider(
        notifier: state,
        child: MaterialApp(theme: CyberTheme.light, home: const HomeScreen()),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Streak ↗'));
    await tester.pumpAndSettle();
    expect(find.byType(ActivityHistorySheet), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
  testWidgets(
    'Deletion requires password and consent, blocks dismissal during cleanup',
    (tester) async {
      final state = AppState(questionBundle: EmptyQuestions());
      final barrier = Completer<void>();
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.light,
          home: Scaffold(
            body: DeleteAccountSheet(
              email: 'test@example.com',
              state: state,
              delete: (password, pause) async {
                calls++;
                await pause();
                await barrier.future;
                throw StateError('offline');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      FilledButton button() => tester.widget(
        find.widgetWithText(FilledButton, 'Hapus akun permanen'),
      );
      await capturePreview(tester, 'delete_account');
      expect(button().onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'password123');
      await tester.pump();
      expect(button().onPressed, isNull);
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      expect(button().onPressed, isNotNull);
      await tester.ensureVisible(find.text('Hapus akun permanen'));
      await tester.tap(find.text('Hapus akun permanen'));
      await tester.pump();
      expect(calls, 1);
      expect(state.accountDeletionStarted, true);
      expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, false);
      barrier.complete();
      await tester.pumpAndSettle();
      expect(find.textContaining('Penghapusan belum selesai'), findsOneWidget);
      expect(find.text('Tetap belajar'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    },
  );
}
