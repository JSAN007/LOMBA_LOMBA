import 'package:flutter/material.dart';

import '../../state/app_state_provider.dart';
import '../lesson/lesson_screen.dart';
import '../../components/practice_header.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final theme = Theme.of(context);
    const tiers = ['Awam', 'Dasar', 'Menengah', 'Lanjutan', 'Pro'];
    void start(int level) {
      state.startPractice(level);
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const LessonScreen()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: 51,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return PracticeHeader(
              completed: state.completedCourseLevels,
              onStartPath: start,
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Icon(
                completed
                    ? Icons.check_circle_rounded
                    : unlocked
                    ? Icons.play_circle_outline_rounded
                    : Icons.lock_outline_rounded,
                color: unlocked
                    ? theme.colorScheme.primary
                    : theme.disabledColor,
              ),
              title: Text('Level $index · ${tiers[(index - 1) ~/ 10]}'),
              subtitle: Text(
                completed
                    ? 'Selesai · Latihan ulang'
                    : unlocked
                    ? 'Latihan deteksi phishing'
                    : 'Selesaikan level ${index - 1}',
              ),
              trailing: unlocked
                  ? const Icon(Icons.chevron_right_rounded)
                  : null,
              onTap: unlocked ? () => start(index) : null,
            ),
          );
        },
      ),
    );
  }
}
