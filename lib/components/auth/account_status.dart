import 'package:flutter/material.dart';
import '../../services/account_service.dart';

class AccountStatus extends StatelessWidget {
  const AccountStatus({
    super.key,
    required this.title,
    required this.message,
    required this.action,
    required this.onAction,
    this.busy = false,
    this.onSecondary,
  });
  final String title, message, action;
  final VoidCallback onAction;
  final bool busy;
  final VoidCallback? onSecondary;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: _body(context),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 72,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 28),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: busy ? null : onAction,
          child: Text(busy ? 'Memproses…' : action),
        ),
        if (onSecondary != null)
          TextButton(
            onPressed: busy ? null : onSecondary,
            child: const Text('Kirim ulang email'),
          ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: busy
              ? null
              : () async {
                  try {
                    await AccountService.auth.signOut();
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gagal keluar. Coba lagi.'),
                        ),
                      );
                    }
                  }
                },
          child: const Text('Keluar dari akun'),
        ),
      ],
    );
  }
}

class AccountVerification extends StatefulWidget {
  const AccountVerification({super.key});
  @override
  State<AccountVerification> createState() => _AccountVerificationState();
}

class _AccountVerificationState extends State<AccountVerification> {
  bool _busy = false;
  String? _message;
  DateTime? _lastSent;
  Future<void> _check({bool resend = false}) async {
    if (resend &&
        _lastSent != null &&
        DateTime.now().difference(_lastSent!).inSeconds < 60) {
      setState(() => _message = 'Tunggu satu menit sebelum mengirim ulang.');
      return;
    }
    setState(() => _busy = true);
    try {
      if (resend) {
        await AccountService.auth.currentUser!.sendEmailVerification();
        _lastSent = DateTime.now();
        if (mounted) {
          setState(
            () =>
                _message = 'Email verifikasi dikirim. Periksa inbox dan spam.',
          );
        }
      } else {
        await AccountService.auth.currentUser!.reload();
        if (mounted && !AccountService.auth.currentUser!.emailVerified) {
          setState(
            () => _message =
                'Email belum terverifikasi. Buka tautan di email terlebih dahulu.',
          );
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _message = AccountService.errorMessage(error));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AccountStatus(
    title: 'Cek email kamu',
    message:
        _message ??
        'Buka tautan verifikasi yang dikirim ke ${AccountService.auth.currentUser?.email}. Setelah itu, lanjutkan di sini.',
    action: 'Saya sudah verifikasi',
    busy: _busy,
    onAction: () => _check(),
    onSecondary: () => _check(resend: true),
  );
}
