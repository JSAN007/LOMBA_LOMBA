import 'dart:io';
import 'package:cybernusa/core/theme/cyber_colors.dart';
import 'package:cybernusa/core/theme/cyber_theme.dart';
import 'package:cybernusa/screens/home/home_screen.dart';
import 'package:cybernusa/screens/lesson/lesson_screen.dart';
import 'package:cybernusa/screens/onboarding/onboarding_screen.dart';
import 'package:cybernusa/screens/practice/practice_screen.dart';
import 'package:cybernusa/screens/result/result_screen.dart';
import 'package:cybernusa/screens/settings/settings_screen.dart';
import 'package:cybernusa/state/app_state.dart';
import 'package:cybernusa/state/app_state_provider.dart';
import 'package:cybernusa/state/theme_controller.dart';
import 'package:cybernusa/state/theme_provider.dart';
import 'package:cybernusa/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _luminance(Color c) => c.computeLuminance();

/// Relative luminance contrast ratio, WCAG 2.x definition.
double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

/// Every screen reachable from the shell, minus the ones needing a live
/// network image. Each is pumped alone so IndexedStack cannot stack two tabs
/// in the same route.
final _screens = <(String, Widget Function())>[
  ('home', () => const HomeScreen()),
  ('practice', () => const PracticeScreen()),
  ('onboarding', () => const OnboardingScreen()),
  ('settings', () => const SettingsScreen()),
];

// Leaderboard and Profile are excluded: they load network images and already
// overflow their fixed podium height at the default 800x600 test surface,
// which is a pre-existing layout issue unrelated to theming.

/// Mounts [child] under the real theme for [mode], with the app's providers.
class _ThemeQuestions extends Fake implements AssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      File('assets/data/questions.json').readAsStringSync();
}

Future<void> _pump(
  WidgetTester tester,
  ThemeMode mode,
  Widget child, {
  ThemeController? controller,
}) async {
  final themeController = controller ?? ThemeController();
  final state = AppState(questionBundle: _ThemeQuestions());
  if (child is LessonScreen) state.startLesson(state.levels.first);
  addTearDown(state.dispose);
  if (controller != null) {
    // Flip the controller into the requested mode.
    if ((mode == ThemeMode.dark) != themeController.isDarkMode) {
      themeController.toggle();
    }
  }

  // Mirrors app.dart: the ListenableBuilder is what makes the toggle visible
  // to MaterialApp, so a test harness must rebuild the same way.
  await tester.pumpWidget(
    ThemeProvider(
      notifier: themeController,
      child: AppStateProvider(
        notifier: state,
        child: ListenableBuilder(
          listenable: themeController,
          builder: (context, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: CyberTheme.light,
            darkTheme: CyberTheme.dark,
            themeMode: themeController.mode,
            home: child,
          ),
        ),
      ),
    ),
  );
}

/// The painted chip inside a floating [SnackBar], excluding the full-width
/// widget box and the transparent scrim Material underneath.
Finder _visibleChip(WidgetTester tester) => find.descendant(
      of: find.byType(SnackBar),
      matching: find.byType(Material),
    ).first;

void main() {
  group('CyberPalette', () {
    test('light mode uses dark ink, dark mode uses light ink', () {
      expect(_luminance(CyberPalette.light.textPrimary),
          lessThan(_luminance(CyberPalette.light.background)));
      expect(_luminance(CyberPalette.dark.textPrimary),
          greaterThan(_luminance(CyberPalette.dark.background)));
    });

    test('primary text meets 4.5:1 against background in both modes', () {
      expect(
        _contrast(CyberPalette.light.textPrimary, CyberPalette.light.background),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(CyberPalette.dark.textPrimary, CyberPalette.dark.background),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('secondary and muted text stay legible on surface', () {
      for (final palette in [CyberPalette.light, CyberPalette.dark]) {
        expect(
          _contrast(palette.textSecondary, palette.surface),
          greaterThanOrEqualTo(4.5),
          reason: 'textSecondary on ${palette.brightness}',
        );
        expect(
          _contrast(palette.textMuted, palette.surface),
          greaterThanOrEqualTo(3.0),
          reason: 'textMuted on ${palette.brightness}',
        );
      }
    });

    test('text is legible against surfaceAlt and surfaceSunken too', () {
      for (final palette in [CyberPalette.light, CyberPalette.dark]) {
        for (final surface in [palette.surfaceAlt, palette.surfaceSunken]) {
          expect(
            _contrast(palette.textPrimary, surface),
            greaterThanOrEqualTo(4.5),
            reason: 'textPrimary on $surface in ${palette.brightness}',
          );
        }
      }
    });

    test('onAccent ink stays readable on every pastel accent', () {
      const accents = <Color>[
        CyberColors.primary,
        CyberColors.secondary,
        CyberColors.accentGreen,
        CyberColors.accentRed,
        CyberColors.accentYellow,
        CyberColors.accentOrange,
        CyberColors.ctaEnd,
        CyberColors.rankGold,
        CyberColors.rankBronze,
      ];

      for (final palette in [CyberPalette.light, CyberPalette.dark]) {
        for (final accent in accents) {
          expect(
            _contrast(palette.onAccent, accent),
            greaterThanOrEqualTo(4.5),
            reason: 'onAccent on $accent in ${palette.brightness}',
          );
        }
      }
    });
  });

  group('CyberTheme', () {
    test('every text role carries an explicit, readable colour', () {
      final themes = {
        CyberTheme.light: CyberPalette.light,
        CyberTheme.dark: CyberPalette.dark,
      };

      for (final entry in themes.entries) {
        final textTheme = entry.key.textTheme;
        final palette = entry.value;

        for (final role in _textRoles) {
          final style = role.read(textTheme);
          expect(style, isNotNull,
              reason: '${role.name} missing in ${palette.brightness}');
          expect(style!.color, isNotNull,
              reason: '${role.name} has null color in ${palette.brightness}');
          expect(
            _contrast(style.color!, palette.background),
            greaterThanOrEqualTo(4.5),
            reason: '${role.name} is unreadable in ${palette.brightness}',
          );
        }
      }
    });

    test('brightness, scaffold and palette extension track each other', () {
      expect(CyberTheme.light.brightness, Brightness.light);
      expect(CyberTheme.dark.brightness, Brightness.dark);
      expect(CyberTheme.light.scaffoldBackgroundColor,
          CyberPalette.light.background);
      expect(CyberTheme.dark.scaffoldBackgroundColor,
          CyberPalette.dark.background);

      for (final theme in [CyberTheme.light, CyberTheme.dark]) {
        final palette = theme.extension<CyberPalette>()!;
        expect(palette.brightness, theme.brightness);
      }
    });
  });

  group('ThemeController', () {
    test('starts light and toggles both ways', () {
      final controller = ThemeController();
      expect(controller.mode, ThemeMode.light);
      expect(controller.isDarkMode, isFalse);

      controller.toggle();
      expect(controller.mode, ThemeMode.dark);
      expect(controller.isDarkMode, isTrue);

      controller.toggle();
      expect(controller.mode, ThemeMode.light);
    });

    test('notifies listeners on toggle', () {
      final controller = ThemeController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.toggle();
      controller.toggle();

      expect(notifications, 2);
    });
  });

  group('screens in both modes', () {
    for (final (name, build) in _screens) {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        testWidgets('$name in $mode paints no unthemed ink', (tester) async {
          await _pump(tester, mode, build());
          await tester.pump(const Duration(milliseconds: 600));

          final offenders = <String>[];

          for (final text in tester.widgetList<Text>(find.byType(Text))) {
            final element = tester.element(find.byWidget(text));
            final color = text.style?.color ??
                DefaultTextStyle.of(element).style.color ??
                const Color(0xFF000000);
            if (color == Colors.white || color == Colors.black) {
              offenders.add('"${text.data}" -> $color');
            }
          }

          expect(offenders, isEmpty);
        });
      }
    }
  });

  group('settings toggle', () {
    testWidgets('switches theme and text colour, then switches back',
        (tester) async {
      final controller = ThemeController();
      await _pump(tester, ThemeMode.light, const SettingsScreen(),
          controller: controller);

      final switchTile = find.byKey(const Key('dark-mode-switch'));
      expect(switchTile, findsOneWidget);

      // Re-read the theme each time: the first ThemeData snapshot does not
      // follow a rebuild on its own.
      ThemeData activeTheme() => Theme.of(tester.element(switchTile));
      Color bodyColor() => activeTheme().textTheme.bodyLarge!.color!;
      CyberPalette palette() =>
          activeTheme().extension<CyberPalette>()!;

      expect(activeTheme().brightness, Brightness.light);
      expect(palette().brightness, Brightness.light);
      final lightBody = bodyColor();
      expect(_luminance(lightBody), lessThan(0.5),
          reason: 'light mode body text should be dark ink');

      await tester.tap(switchTile);
      await tester.pumpAndSettle();

      expect(activeTheme().brightness, Brightness.dark);
      expect(palette().brightness, Brightness.dark);
      final darkBody = bodyColor();
      expect(_luminance(darkBody), greaterThan(0.5),
          reason: 'dark mode body text should be light ink');
      expect(_luminance(darkBody), greaterThan(_luminance(lightBody)));

      await tester.tap(switchTile);
      await tester.pumpAndSettle();

      expect(activeTheme().brightness, Brightness.light);
      expect(bodyColor(), lightBody);
    });

    testWidgets('subtitle reflects the active mode', (tester) async {
      final controller = ThemeController();
      await _pump(tester, ThemeMode.light, const SettingsScreen(),
          controller: controller);

      expect(find.text('Tampilan terang aktif'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dark-mode-switch')));
      await tester.pumpAndSettle();

      expect(find.text('Tampilan gelap aktif'), findsOneWidget);
      expect(find.text('Dark palette'), findsOneWidget);
    });
  });

  group('snackbar width', () {
    testWidgets('never spans wider than the app column', (tester) async {
      // Wide window: the snackbar must stay pinned to the 480px app column
      // instead of stretching across the viewport.
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _pump(tester, ThemeMode.light, const HomeScreen());
      await tester.pump(const Duration(milliseconds: 600));

      // "Social Engineering" is a locked level, so tapping it raises the
      // snackbar.
      await tester.tap(find.text('Social Engineering'));
      await tester.pump(const Duration(milliseconds: 300));

      final snackBar = find.byType(SnackBar);
      expect(snackBar, findsOneWidget);

      // A floating SnackBar lays out full-width and constrains the visible
      // chip internally, so measure the chip itself, not the widget box.
      final width = tester.getSize(_visibleChip(tester)).width;
      expect(width, lessThanOrEqualTo(kAppColumnMaxWidth));
      expect(
        width,
        lessThan(tester.view.physicalSize.width / tester.view.devicePixelRatio),
        reason: 'snackbar must not span the whole window',
      );
    });

    testWidgets('fits the window on a narrow phone', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _pump(tester, ThemeMode.light, const HomeScreen());
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(find.text('Social Engineering'));
      await tester.pump(const Duration(milliseconds: 300));

      final width = tester.getSize(_visibleChip(tester)).width;
      expect(width, lessThanOrEqualTo(390 - 32));
      expect(width, greaterThan(0));
    });

    testWidgets('carries readable text in both modes', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;

        await _pump(tester, mode, const HomeScreen());
        await tester.pump(const Duration(milliseconds: 600));

        await tester.tap(find.text('Social Engineering'));
        await tester.pump(const Duration(milliseconds: 300));

        final element = tester.element(find.byType(SnackBar));
        final palette = Theme.of(element).extension<CyberPalette>()!;
        final background =
            Theme.of(element).snackBarTheme.backgroundColor!;

        expect(
          _contrast(palette.background, background),
          greaterThanOrEqualTo(4.5),
          reason: 'snackbar text on chip in $mode',
        );
      }
      tester.view.reset();
    });
  });

  group('result screen', () {
    testWidgets('score text is readable in both modes', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await _pump(
          tester,
          mode,
          const ResultScreen(
            xpEarned: 60,
            isSuccess: true,
            score: 3,
            totalQuestions: 5,
          ),
        );

        final value = find.textContaining('60');
        final element = tester.element(value);
        final palette = Theme.of(element).extension<CyberPalette>()!;
        final color = tester.widget<Text>(value).style!.color!;

        expect(
          _contrast(color, palette.surface),
          greaterThanOrEqualTo(4.5),
          reason: 'XP value on surface in $mode',
        );
      }
    });
  });

  group('lesson feedback panel', () {
    testWidgets('verdict text is readable on the verdict fill', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        for (final isCorrect in [true, false]) {
          await _pump(tester, mode, const LessonScreen());

          // Answer through the app state so the feedback panel renders.
          final state = AppStateProvider.of(
              tester.element(find.byType(LessonScreen)));
          final q = state.currentQuestion;
          state.answerQuestion(isCorrect ? q.correctAnswerIndex : (q.correctAnswerIndex + 1) % q.options.length);

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));

          final palette = Theme.of(tester.element(find.byType(LessonScreen)))
              .extension<CyberPalette>()!;
          final fill = isCorrect
              ? CyberColors.accentGreen
              : CyberColors.accentRed;

          expect(
            _contrast(palette.onAccent, fill),
            greaterThanOrEqualTo(4.5),
            reason: 'verdict ink on $fill in $mode',
          );
        }
      }
    });
  });
}

/// The text roles the app actually renders.
typedef _Role = ({String name, TextStyle? Function(TextTheme) read});

const _textRoles = <_Role>[
  (name: 'displayLarge', read: _displayLarge),
  (name: 'displayMedium', read: _displayMedium),
  (name: 'displaySmall', read: _displaySmall),
  (name: 'headlineLarge', read: _headlineLarge),
  (name: 'headlineMedium', read: _headlineMedium),
  (name: 'headlineSmall', read: _headlineSmall),
  (name: 'titleLarge', read: _titleLarge),
  (name: 'titleMedium', read: _titleMedium),
  (name: 'titleSmall', read: _titleSmall),
  (name: 'bodyLarge', read: _bodyLarge),
  (name: 'bodyMedium', read: _bodyMedium),
  (name: 'bodySmall', read: _bodySmall),
  (name: 'labelLarge', read: _labelLarge),
  (name: 'labelMedium', read: _labelMedium),
  (name: 'labelSmall', read: _labelSmall),
];

TextStyle? _displayLarge(TextTheme t) => t.displayLarge;
TextStyle? _displayMedium(TextTheme t) => t.displayMedium;
TextStyle? _displaySmall(TextTheme t) => t.displaySmall;
TextStyle? _headlineLarge(TextTheme t) => t.headlineLarge;
TextStyle? _headlineMedium(TextTheme t) => t.headlineMedium;
TextStyle? _headlineSmall(TextTheme t) => t.headlineSmall;
TextStyle? _titleLarge(TextTheme t) => t.titleLarge;
TextStyle? _titleMedium(TextTheme t) => t.titleMedium;
TextStyle? _titleSmall(TextTheme t) => t.titleSmall;
TextStyle? _bodyLarge(TextTheme t) => t.bodyLarge;
TextStyle? _bodyMedium(TextTheme t) => t.bodyMedium;
TextStyle? _bodySmall(TextTheme t) => t.bodySmall;
TextStyle? _labelLarge(TextTheme t) => t.labelLarge;
TextStyle? _labelMedium(TextTheme t) => t.labelMedium;
TextStyle? _labelSmall(TextTheme t) => t.labelSmall;
