import 'package:flutter/material.dart';

import 'core/theme/cyber_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'state/app_state.dart';
import 'state/app_state_provider.dart';
import 'state/profile_controller.dart';
import 'state/theme_controller.dart';
import 'state/theme_provider.dart';
import 'widgets/responsive_layout_wrapper.dart';

class SecuriGoApp extends StatefulWidget {
  const SecuriGoApp({super.key});

  @override
  State<SecuriGoApp> createState() => _SecuriGoAppState();
}

class _SecuriGoAppState extends State<SecuriGoApp> {
  late final AppState _appState;
  final ThemeController _themeController = ThemeController();
  final ProfileController _profileController = ProfileController();

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  void dispose() {
    _appState.dispose();
    _themeController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      notifier: _appState,
      child: ProfileProvider(
        notifier: _profileController,
        child: ThemeProvider(
          notifier: _themeController,
          child: ListenableBuilder(
            listenable: _themeController,
            builder: (context, _) => MaterialApp(
              title: 'SecuriGo',
              debugShowCheckedModeBanner: false,
              theme: CyberTheme.light,
              darkTheme: CyberTheme.dark,
              themeMode: _themeController.mode,
              builder: (context, child) => ResponsiveLayoutWrapper(
                child: child ?? const SizedBox.shrink(),
              ),
              home: const SplashScreen(),
            ),
          ),
        ),
      ),
    );
  }
}
