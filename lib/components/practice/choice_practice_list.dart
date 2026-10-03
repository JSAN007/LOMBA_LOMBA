import 'package:flutter/material.dart';

import '../../state/app_state_provider.dart';
import '../../screens/lesson/lesson_screen.dart';
import '../practice_header.dart';

class ChoicePracticeList extends StatelessWidget {
  const ChoicePracticeList({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return ListView.separated(
      key: const PageStorageKey('choice-practice'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      itemCount: 51,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return PracticeHeader(
            completed: state.completedCourseLevels,
            onStartPath: (level) {
              state.startPractice(level);
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LessonScreen()));
            },
          );
        }
        return _PracticeLevelCard(level: index);
      },
    );
  }
}

class _PracticeLevelCard extends StatelessWidget {
  const _PracticeLevelCard({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final theme = Theme.of(context);
    const tiers = ['Awam', 'Dasar', 'Menengah', 'Lanjutan', 'Pro'];
    final unlocked = state.isPracticeUnlocked(level);
    final completed = state.completedPracticeLevels.contains(level);
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
          completed
              ? Icons.check_circle_rounded
              : unlocked
              ? Icons.play_circle_outline_rounded
              : Icons.lock_outline_rounded,
          color: unlocked ? theme.colorScheme.primary : theme.disabledColor,
        ),
        title: Text('Level $level · ${tiers[(level - 1) ~/ 10]}'),
        subtitle: Text(
          completed
              ? 'Selesai · Latihan ulang'
              : unlocked
              ? 'Latihan deteksi phishing'
              : 'Selesaikan level ${level - 1}',
        ),
        trailing: unlocked ? const Icon(Icons.chevron_right_rounded) : null,
        onTap: unlocked
            ? () {
                state.startPractice(level);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LessonScreen()),
                );
              }
            : null,
      ),
    );
  }
}
