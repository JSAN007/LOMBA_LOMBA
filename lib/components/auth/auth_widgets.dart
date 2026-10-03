import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.register});
  final bool register;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.primary.withValues(alpha: .18),
                colors.secondary.withValues(alpha: .16),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(Icons.security_rounded, size: 36, color: colors.primary),
        ),
        const SizedBox(height: 24),
        Text(
          'SECURIGO / YOUR SAFE SPACE',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          register
              ? 'Langkah kecil,\nproteksi besar.'
              : 'Selamat datang\nkembali.',
          style: theme.textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          register
              ? 'Buat akun dan mulai perjalananmu menjadi lebih aman di dunia digital.'
              : 'Masuk untuk melanjutkan perjalanan belajar keamanan digitalmu.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.password = false,
    this.hidden = false,
    this.onToggle,
    this.email = false,
    this.enabled = true,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final bool password, hidden, email, enabled;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        validator: validator,
        obscureText: hidden,
        autocorrect: !password && !email,
        enableSuggestions: !password,
        keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
        textInputAction: TextInputAction.next,
        autofillHints: [
          email
              ? AutofillHints.email
              : password
              ? AutofillHints.password
              : AutofillHints.name,
        ],
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: colors.surface,
          prefixIcon: Icon(icon, color: colors.onSurfaceVariant),
          suffixIcon: password
              ? IconButton(
                  onPressed: enabled ? onToggle : null,
                  tooltip: hidden ? 'Lihat password' : 'Sembunyikan password',
                  icon: Icon(
                    hidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}

class AuthNotice extends StatelessWidget {
  const AuthNotice({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium,
        semanticsLabel: message,
      ),
    );
  }
}
