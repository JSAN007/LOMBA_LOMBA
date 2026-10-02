import 'package:flutter/material.dart';
import '../../components/auth/auth_widgets.dart';
import '../../services/account_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _register = false, _hidden = true, _busy = false;
  String? _message;

  @override
  void dispose() {
    for (final controller in [_name, _email, _password, _confirm]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit({bool reset = false}) async {
    if (reset) {
      if (!_email.text.trim().contains('@')) {
        setState(() => _message = 'Isi email akun kamu terlebih dahulu.');
        return;
      }
    } else if (!_form.currentState!.validate()) {
      return;
    }
    if (!AccountService.configured) {
      setState(
        () => _message =
            'Layanan akun belum tersedia. Silakan coba lagi setelah konfigurasi aplikasi selesai.',
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      if (reset) {
        await AccountService.auth.sendPasswordResetEmail(
          email: _email.text.trim(),
        );
        if (mounted) {
          setState(
            () => _message =
                'Jika email terdaftar, instruksi reset password akan dikirim. Periksa juga folder spam.',
          );
        }
      } else if (_register) {
        await AccountService.register(
          _name.text.trim(),
          _email.text.trim(),
          _password.text,
        );
      } else {
        await AccountService.auth.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _content(theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: AuthHeader(key: ValueKey(_register), register: _register),
        ),
        const SizedBox(height: 28),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Masuk')),
            ButtonSegment(value: true, label: Text('Daftar')),
          ],
          selected: {_register},
          showSelectedIcon: false,
          onSelectionChanged: _busy
              ? null
              : (value) => setState(() {
                  _register = value.first;
                  _message = null;
                  _form.currentState?.reset();
                  _password.clear();
                  _confirm.clear();
                }),
        ),
        const SizedBox(height: 28),
        if (_message != null) AuthNotice(message: _message!),
        AutofillGroup(
          child: Form(
            key: _form,
            child: Column(children: _fields()),
          ),
        ),
        if (!_register)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _busy ? null : () => _submit(reset: true),
              child: const Text('Lupa password?'),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _busy ? null : _submit,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _busy
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  _register ? 'Buat akun' : 'Masuk ke SecuriGo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: 24),
        Text(
          'Belajar lebih aman, satu langkah setiap hari.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  List<Widget> _fields() => [
    if (_register)
      AuthField(
        controller: _name,
        label: 'Nama kamu',
        icon: Icons.person_outline_rounded,
        enabled: !_busy,
        validator: (value) =>
            (value ?? '').trim().length < 2 || (value ?? '').trim().length > 60
            ? 'Gunakan nama 2–60 karakter.'
            : null,
      ),
    AuthField(
      controller: _email,
      label: 'Email',
      icon: Icons.alternate_email_rounded,
      email: true,
      enabled: !_busy,
      validator: (value) =>
          RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch((value ?? '').trim())
          ? null
          : 'Masukkan email yang valid.',
    ),
    AuthField(
      controller: _password,
      label: 'Password',
      icon: Icons.lock_outline_rounded,
      password: true,
      hidden: _hidden,
      enabled: !_busy,
      onToggle: () => setState(() => _hidden = !_hidden),
      validator: (value) => (value ?? '').isEmpty
          ? 'Isi password kamu.'
          : _register && value!.length < 8
          ? 'Gunakan minimal 8 karakter.'
          : null,
    ),
    if (_register)
      AuthField(
        controller: _confirm,
        label: 'Konfirmasi password',
        icon: Icons.verified_user_outlined,
        password: true,
        hidden: _hidden,
        enabled: !_busy,
        onToggle: () => setState(() => _hidden = !_hidden),
        validator: (value) =>
            value == _password.text ? null : 'Password belum sama.',
      ),
  ];
}
