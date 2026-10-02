import 'package:flutter/material.dart';

import '../../state/app_state_provider.dart';
import '../lesson/lesson_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final theme = Theme.of(context);
    const tiers = ['Awam', 'Dasar', 'Menengah', 'Lanjutan', 'Pro'];

    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: 51,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text(
              '50 level · Awam hingga Pro\n'
              'Mulai langsung di level 1, 11, 21, 31, atau 41. '
              'Selesaikan latihan untuk membuka level berikutnya.\n'
              'Latihan menggunakan bank soal phishing yang tersedia. '
              'Progres tersimpan selama aplikasi berjalan.',
              style: theme.textTheme.bodyMedium,
            );
          }
          final unlocked = state.isPracticeUnlocked(index);
          final completed = state.completedPracticeLevels.contains(index);
          return Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: ListTile(
              enabled: unlocked,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Icon(
                completed ? Icons.check_circle_rounded
                    : unlocked ? Icons.play_circle_outline_rounded : Icons.lock_outline_rounded,
                color: unlocked ? theme.colorScheme.primary : theme.disabledColor,
              ),
              title: Text('Level $index · ${tiers[(index - 1) ~/ 10]}'),
              subtitle: Text(completed ? 'Selesai · Latihan ulang'
                  : unlocked ? 'Latihan deteksi phishing' : 'Selesaikan level ${index - 1}'),
              trailing: unlocked ? const Icon(Icons.chevron_right_rounded) : null,
              onTap: unlocked ? () {
                state.startPractice(index);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LessonScreen()),
                );
              } : null,
            ),
          );
        },
      ),
    );
  }
}
