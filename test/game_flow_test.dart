import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cybernusa/core/theme/cyber_theme.dart';
import 'package:cybernusa/state/app_state.dart';
import 'package:cybernusa/state/app_state_provider.dart';
import 'package:cybernusa/screens/lesson/lesson_screen.dart';

class LoadedBundle extends Fake implements AssetBundle {
  final String questions;
  LoadedBundle(this.questions);
  @override
  Future<String> loadString(String key, {bool cache = true}) async => questions;
}

void main() {
  testWidgets('Complete game returns to the retained Practice route', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    GoogleFonts.config.allowRuntimeFetching = false;
    final theme = await tester.runAsync(() async {
      final theme = CyberTheme.dark;
      await GoogleFonts.pendingFonts();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      return theme;
    });
    final state = AppState(
      questionBundle: LoadedBundle(
        File('assets/data/questions.json').readAsStringSync(),
      ),
    );
    const captureKey = ValueKey('capture-game');
    await tester.pumpWidget(
      AppStateProvider(
        notifier: state,
        child: MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    state.startPractice(1);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RepaintBoundary(
                          key: captureKey,
                          child: LessonScreen(),
                        ),
                      ),
                    );
                  },
                  child: const Text('Practice list'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Practice list'));
    await tester.pumpAndSettle();
    if (const bool.fromEnvironment('CAPTURE_GAME')) {
      await tester.runAsync(() async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(captureKey),
        );
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        Directory('artifacts/previews').createSync(recursive: true);
        File(
          'artifacts/previews/cyber_quest.png',
        ).writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
    final count = state.currentLessonQuestions.length;
    for (var question = 0; question < count; question++) {
      final answer = state
          .currentQuestion
          .options[state.currentQuestion.correctAnswerIndex];
      await tester.ensureVisible(find.text(answer));
      await tester.pumpAndSettle();
      await tester.tap(find.text(answer));
      await tester.pumpAndSettle();
      final next = find.text(
        question == count - 1 ? 'Lihat hasil misi' : 'Lanjutkan',
      );
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(find.text('Misi ditaklukkan!'), findsOneWidget);
    expect(find.text('Kembali ke Practice'), findsOneWidget);
    expect(state.completedPracticeLevels.contains(1), isTrue);
    expect(state.isPracticeUnlocked(2), isTrue);
    await tester.tap(find.text('Kembali ke Practice'));
    await tester.pumpAndSettle();
    expect(find.text('Practice list'), findsOneWidget);
    expect(find.text('Welcome to SecuriGo.'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
