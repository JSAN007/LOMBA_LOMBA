import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/account_service.dart';
import '../../state/app_state_provider.dart';
import '../../state/app_state.dart';
import '../../services/progress_store.dart';
import '../../components/auth/account_status.dart';
import '../main_shell.dart';
import 'auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    if (!AccountService.configured) return const AuthScreen();
    return StreamBuilder<User?>(
      stream: AccountService.auth.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) return const AuthScreen();
        return AccountSession(key: ValueKey(user.uid), user: user);
      },
    );
  }
}

class AccountSession extends StatefulWidget {
  const AccountSession({super.key, required this.user});
  final User user;
  @override
  State<AccountSession> createState() => _AccountSessionState();
}

class _AccountSessionState extends State<AccountSession> {
  Future<void>? _profile;
  late final AppState _state;

  @override
  void initState() {
    super.initState();
    _state = AppState(progressStore: FirestoreProgressStore(widget.user.uid))
      ..username = widget.user.displayName ?? 'Pelajar';
  }

  Future<void> _loadAccount() async {
    await AccountService.ensureProfile(widget.user);
    await _state.loadProgress();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.user.emailVerified) return const AccountVerification();
    _profile ??= _loadAccount();
    return FutureBuilder<void>(
      future: _profile,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AccountStatus(
            title: 'Profil belum bisa dimuat',
            message: 'Periksa koneksi dan coba lagi.',
            action: 'Coba lagi',
            onAction: () => setState(() => _profile = null),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        _state.username = widget.user.displayName ?? 'Pelajar';
        return AppStateProvider(
          notifier: _state,
          child: Navigator(
            onGenerateRoute: (settings) => MaterialPageRoute<void>(
              settings: settings,
              builder: (context) => const MainShell(),
            ),
          ),
        );
      },
    );
  }
}
