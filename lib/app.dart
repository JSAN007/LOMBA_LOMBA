import 'package:flutter/material.dart';

import 'core/theme/cyber_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'state/app_state.dart';
import 'state/app_state_provider.dart';
import 'widgets/responsive_layout_wrapper.dart';

class SecuriGoApp extends StatefulWidget {
  const SecuriGoApp({super.key});

  @override
  State<SecuriGoApp> createState() => _SecuriGoAppState();
}

class _SecuriGoAppState extends State<SecuriGoApp> {
  late AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      notifier: _appState,
      child: MaterialApp(
        title: 'SecuriGo',
        debugShowCheckedModeBanner: false,
        theme: CyberTheme.darkTheme,
        builder: (context, child) => ResponsiveLayoutWrapper(
          child: child ?? const SizedBox.shrink(),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
