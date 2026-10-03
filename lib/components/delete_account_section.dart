import 'package:flutter/material.dart';
import '../services/account_service.dart';
import '../services/account_deletion_service.dart';
import '../state/app_state.dart';
import '../state/app_state_provider.dart';

class DeleteAccountSection extends StatelessWidget {
  const DeleteAccountSection({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = AccountService.configured
        ? AccountService.auth.currentUser
        : null;
    return Card(
      elevation: 0,
      color: colors.errorContainer.withValues(alpha: .25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.error.withValues(alpha: .25)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(Icons.person_remove_outlined, color: colors.error),
        title: Text(
          'Hapus akun',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: colors.error),
        ),
        subtitle: Text(
          user == null
              ? 'Tersedia setelah masuk dengan akun.'
              : 'Hapus akun, progres, riwayat, dan koneksi teman secara permanen.',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: user == null
            ? null
            : () {
                final state = AppStateProvider.of(context);
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: false,
                  enableDrag: false,
                  useSafeArea: true,
                  builder: (_) => DeleteAccountSheet(
                    email: user.email ?? '',
                    state: state,
                    delete: (password, pause) => AccountDeletionService(
                      user: user,
                    ).delete(password: password, pauseWrites: pause),
                  ),
                );
              },
      ),
    );
  }
}

class DeleteAccountSheet extends StatefulWidget {
  const DeleteAccountSheet({
    super.key,
    required this.email,
    required this.state,
    required this.delete,
  });
  final String email;
  final AppState state;
  final Future<void> Function(String, Future<void> Function()) delete;
  @override
  State<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<DeleteAccountSheet> {
  final password = TextEditingController();
  bool confirmed = false, busy = false;
  String? error;
  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || !confirmed || password.text.isEmpty) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.delete(password.text, widget.state.prepareAccountDeletion);
      // AuthGate observes User.delete() and replaces the entire account session.
      if (mounted) Navigator.of(context).pop();
    } catch (exception) {
      if (mounted) {
        setState(
          () => error = widget.state.accountDeletionStarted
              ? 'Penghapusan belum selesai. Sebagian data mungkin sudah dihapus. Periksa koneksi, lalu coba lagi untuk menuntaskan penghapusan.'
              : AccountService.errorMessage(exception),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: !busy && !widget.state.accountDeletionStarted,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.person_remove_outlined,
              size: 36,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Tutup perjalanan ini?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.email, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            const Text(
              'XP, progres semua path, riwayat belajar, dan koneksi teman akan dihapus. Tindakan ini tidak bisa dibatalkan. Untuk menggunakan email ini lagi, kamu harus daftar ulang.',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: password,
              enabled: !busy,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Password akun',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: confirmed,
              onChanged: busy
                  ? null
                  : (value) => setState(() => confirmed = value ?? false),
              title: const Text(
                'Saya memahami data dan akun ini akan dihapus permanen.',
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: !busy && confirmed && password.text.isNotEmpty
                    ? submit
                    : null,
                icon: busy
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onError,
                        ),
                      )
                    : const Icon(Icons.delete_forever_outlined),
                label: Text(busy ? 'Menghapus…' : 'Hapus akun permanen'),
              ),
            ),
            if (!widget.state.accountDeletionStarted)
              Center(
                child: TextButton(
                  onPressed: busy ? null : () => Navigator.of(context).pop(),
                  child: const Text('Tetap belajar'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
