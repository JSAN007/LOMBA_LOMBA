import 'package:cybernusa/core/theme/cyber_theme.dart';
import 'package:cybernusa/screens/edit_profile/edit_profile_screen.dart';
import 'package:cybernusa/components/profile/profile_header.dart';
import 'package:cybernusa/models/user_profile.dart';
import 'package:cybernusa/screens/profile/profile_screen.dart';
import 'package:cybernusa/state/app_state.dart';
import 'package:cybernusa/state/app_state_provider.dart';
import 'package:cybernusa/state/profile_controller.dart';
import 'package:cybernusa/state/theme_controller.dart';
import 'package:cybernusa/state/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester,
  ThemeMode mode,
  Widget child, {
  ProfileController? profileController,
}) async {
  final themeController = ThemeController();
  if ((mode == ThemeMode.dark) != themeController.isDarkMode) {
    themeController.toggle();
  }

  await tester.pumpWidget(
    ThemeProvider(
      notifier: themeController,
      child: AppStateProvider(
        notifier: AppState(),
        child: ProfileProvider(
          notifier: profileController ?? ProfileController(),
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
    ),
  );
}

/// Taps a real preset cell. Tapping the GridView itself lands in the gap
/// between cells and silently selects nothing.
Future<void> _tapFirstGridCell(WidgetTester tester) {
  return tester.tap(
    find
        .descendant(
          of: find.byType(GridView),
          matching: find.byType(AnimatedContainer),
        )
        .first,
  );
}

/// [UserProfile.dummy] is pinned to level 27, which always unlocks two
/// badges. This rebuilds the same profile at a different level so the
/// "nothing earned yet" branch can be exercised.
UserProfile _profileAtLevel(int level) {
  final base = UserProfile.dummy();
  return UserProfile(
    id: base.id,
    username: 'Pemula',
    avatarUrl: base.avatarUrl,
    bio: base.bio,
    level: level,
    xpCurrent: base.xpCurrent,
    xpToNext: base.xpToNext,
    globalRank: base.globalRank,
    totalMatches: base.totalMatches,
    wins: base.wins,
    winRate: base.winRate,
    totalPoints: base.totalPoints,
    badges: buildBadges(currentLevel: level),
    avatarPreset: base.avatarPreset,
  );
}

void main() {
  group('Edit Profile', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('renders and opens the avatar picker in $mode', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await _pump(tester, mode, const EditProfileScreen());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Edit Profile'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.camera_alt_rounded));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Pilih Avatar Preset'), findsOneWidget);

        await _tapFirstGridCell(tester);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Pilih Avatar Preset'), findsNothing);
      });

      testWidgets('offers no cover control in $mode', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await _pump(tester, mode, const EditProfileScreen());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.photo_camera_outlined), findsNothing);
        expect(find.textContaining('Cover'), findsNothing);
      });

      testWidgets('name edit previews live and saves in $mode', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final controller = ProfileController();
        await _pump(
          tester,
          mode,
          const EditProfileScreen(),
          profileController: controller,
        );
        await tester.pumpAndSettle();

        // Save is disabled until something actually changes.
        final save = find.widgetWithText(FilledButton, 'Simpan');
        expect(tester.widget<FilledButton>(save).onPressed, isNull);

        await tester.enterText(find.byType(TextField).first, 'Raka Pratama');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Live preview reflects the typed name.
        expect(find.text('Raka Pratama'), findsWidgets);

        final enabledSave = find.widgetWithText(FilledButton, 'Simpan');
        expect(tester.widget<FilledButton>(enabledSave).onPressed, isNotNull);

        await tester.tap(enabledSave);
        await tester.pumpAndSettle();

        expect(controller.profile.username, 'Raka Pratama');
      });

      testWidgets('rejects a too-short name in $mode', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await _pump(tester, mode, const EditProfileScreen());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'ab');
        await tester.pumpAndSettle();

        expect(find.text('Minimal 3 karakter'), findsOneWidget);
        expect(
          tester
              .widget<FilledButton>(find.widgetWithText(FilledButton, 'Simpan'))
              .onPressed,
          isNull,
        );
      });

      // Regression: re-picking the preset that was already saved must not
      // clear a pending rename made in the same visit.
      testWidgets(
        're-picking the original preset keeps Save enabled in $mode',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          final controller = ProfileController();
          final savedAvatar = controller.profile.avatarPreset;

          await _pump(
            tester,
            mode,
            const EditProfileScreen(),
            profileController: controller,
          );
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField).first, 'Raka Pratama');
          await tester.pumpAndSettle();

          // Move the avatar away, then back to the value that was saved.
          await tester.tap(find.byIcon(Icons.camera_alt_rounded));
          await tester.pumpAndSettle();
          await _tapFirstGridCell(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.camera_alt_rounded));
          await tester.pumpAndSettle();
          await tester.tap(
            find
                .descendant(
                  of: find.byType(GridView),
                  matching: find.byType(AnimatedContainer),
                )
                .at(savedAvatar),
          );
          await tester.pumpAndSettle();

          expect(controller.profile.avatarPreset, savedAvatar);
          expect(
            tester
                .widget<FilledButton>(
                  find.widgetWithText(FilledButton, 'Simpan'),
                )
                .onPressed,
            isNotNull,
          );
        },
      );
    }
  });

  group('Profile', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('renders and reaches Edit Profile in $mode', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await _pump(tester, mode, const ProfileScreen());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.scrollUntilVisible(
          find.text('Edit Profile'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Edit Profile'));
        await tester.pumpAndSettle();

        expect(find.text('Edit Profile'), findsWidgets);
        expect(find.byType(EditProfileScreen), findsOneWidget);
      });
    }

    testWidgets('profile reflects an edited name', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final controller = ProfileController();
      controller.updateProfile(
        username: 'Nadia Putri',
        bio: 'Hunter',
        avatarPreset: 3,
      );

      await _pump(
        tester,
        ThemeMode.light,
        const ProfileScreen(),
        profileController: controller,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Nadia Putri'), findsOneWidget);
    });

    // Level 27 unlocks First Blood and Signal Hunter; the other three are
    // still locked and belong only in the achievements card below.
    testWidgets('header strip lists only the earned badges', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _pump(tester, ThemeMode.light, const ProfileScreen());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final strip = find.byType(ProfileHeader);
      expect(
        find.descendant(of: strip, matching: find.text('First Blood')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: strip, matching: find.text('Signal Hunter')),
        findsOneWidget,
      );
      for (final locked in [
        'Firewall Knight',
        'Zero Day Ace',
        'Legend of Cyberspace',
      ]) {
        expect(
          find.descendant(of: strip, matching: find.text(locked)),
          findsNothing,
          reason: '$locked is locked and must stay out of the header',
        );
      }
    });

    testWidgets('header strip opens the badge detail sheet', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _pump(tester, ThemeMode.light, const ProfileScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(ProfileHeader),
          matching: find.text('First Blood'),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Cara mendapatkannya'), findsOneWidget);
    });

    testWidgets('header shows no strip when nothing is unlocked', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Level 1 sits below every badge threshold.
      final controller = ProfileController(initialProfile: _profileAtLevel(1));
      expect(controller.profile.badges.where((b) => b.unlocked), isEmpty);

      await _pump(
        tester,
        ThemeMode.light,
        const ProfileScreen(),
        profileController: controller,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // No empty strip, and the name still renders.
      expect(find.text('Pemula'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ProfileHeader),
          matching: find.text('First Blood'),
        ),
        findsNothing,
      );
    });
  });
}
