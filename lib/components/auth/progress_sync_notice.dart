import 'package:flutter/material.dart';
import '../../state/app_state_provider.dart';

class ProgressSyncNotice extends StatelessWidget {
  const ProgressSyncNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    if (state.progressSaveError == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(
          Icons.cloud_off_rounded,
          color: theme.colorScheme.onErrorContainer,
        ),
        title: Text(
          'Progres belum tersimpan',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
        subtitle: const Text('Periksa koneksi sebelum keluar dari akun.'),
        trailing: TextButton(
          onPressed: () async {
            try {
              await state.saveProgress();
            } catch (_) {
              // The notice remains visible until a write succeeds.
            }
          },
          child: const Text('Coba lagi'),
        ),
      ),
    );
  }
}
