import 'package:flutter/material.dart';

import '../core/widgets/animated_progress_bar.dart';
import '../state/app_state.dart';

class DailyGoalsCard extends StatelessWidget {
  const DailyGoalsCard({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Daily Goals', style: theme.textTheme.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sedikit waktu, kebiasaan yang lebih aman.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          _GoalProgress(
            title: 'Waktu belajar',
            detail: '${state.studyMinutes} / 100 menit',
            progress: state.dailyGoalProgress,
            color: colors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            'Dihitung saat aplikasi aktif. Mulai dari 0 setiap sesi baru.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: colors.outlineVariant, height: 1),
          const SizedBox(height: 20),
          _GoalProgress(
            title: 'Course Progress',
            detail: '${state.completedCourseLevels} / 50 level',
            progress: state.courseProgress,
            color: colors.secondary,
          ),
          const SizedBox(height: 8),
          Text(
            '5 path · ${(state.courseProgress * 100).round()}% selesai',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalProgress extends StatelessWidget {
  const _GoalProgress({
    required this.title,
    required this.detail,
    required this.progress,
    required this.color,
  });

  final String title;
  final String detail;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$title, $detail',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              Text(detail, style: theme.textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedProgressBar(value: progress, color: color, showGlow: false),
        ],
      ),
    );
  }
}
