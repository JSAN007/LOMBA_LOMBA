import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../state/app_state.dart';

class LessonHeader extends StatelessWidget {
  const LessonHeader({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Tinggalkan latihan',
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              final leave = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Tinggalkan misi?'),
                  content: const Text('Progres sesi ini tidak akan disimpan.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
              if (leave == true && context.mounted) Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: Text(
              'MISI ${state.activePracticeLevel ?? state.activeLevel?.id ?? 1}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.6,
              ),
            ),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: GamePill(
                icon: Icons.bolt_rounded,
                text: '${state.sessionXpEarned} XP',
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GamePill(
            icon: Icons.favorite_rounded,
            text: '${state.lives}',
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }
}

class GamePill extends StatelessWidget {
  const GamePill({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });
  final IconData icon;
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class MissionPath extends StatelessWidget {
  const MissionPath({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(state.currentLessonQuestions.length, (index) {
        final passed = index < state.currentQuestionIndex;
        final current = index == state.currentQuestionIndex;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: passed
                  ? colors.primary
                  : current
                  ? colors.secondary
                  : colors.outlineVariant,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }),
    );
  }
}

class MissionCompanion extends StatelessWidget {
  const MissionCompanion({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = state.isAnswered && !state.isCorrect
        ? colors.error
        : colors.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: .16),
            colors.secondary.withValues(alpha: .12),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: accent.withValues(alpha: .2)),
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                'CYBER QUEST',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Checkpoint ${state.currentQuestionIndex + 1}/${state.currentLessonQuestions.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: _CompanionFace(
              key: ValueKey(
                '${state.currentQuestionIndex}-${state.isAnswered}-${state.isCorrect}',
              ),
              icon: state.isAnswered
                  ? state.isCorrect
                        ? Icons.verified_user_rounded
                        : Icons.health_and_safety_rounded
                  : Icons.shield_rounded,
              accent: accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.isAnswered
                ? state.isCorrect
                      ? 'Ancaman berhasil dihalau!'
                      : 'Perisai kena serangan!'
                : 'Lindungi dunia digitalmu.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanionFace extends StatelessWidget {
  const _CompanionFace({super.key, required this.icon, required this.accent});
  final IconData icon;
  final Color accent;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 100,
      width: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: .7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: accent.withValues(alpha: .18), blurRadius: 25),
              ],
            ),
          ),
          Icon(icon, size: 68, color: accent),
          Positioned(
            left: 12,
            top: 12,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: colors.secondary,
              size: 20,
            ),
          ),
          Positioned(
            right: 10,
            bottom: 12,
            child: Icon(Icons.bolt_rounded, color: accent, size: 25),
          ),
        ],
      ),
    );
  }
}

class LessonQuestion extends StatelessWidget {
  const LessonQuestion({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MissionPath(state: state),
        const SizedBox(height: 20),
        MissionCompanion(state: state),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: Text(
            state.currentQuestion.question,
            key: ValueKey(state.currentQuestion.id),
            style: theme.textTheme.titleLarge?.copyWith(height: 1.4),
          ),
        ),
        const SizedBox(height: 12),
        Text('Pilih aksimu', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 340 ? 2 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                state.currentQuestion.options.length,
                (index) => SizedBox(
                  width: width,
                  child: LessonOption(state: state, index: index),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class LessonOption extends StatelessWidget {
  const LessonOption({super.key, required this.state, required this.index});
  final AppState state;
  final int index;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = state.selectedAnswerIndex == index;
    final correct =
        state.isAnswered && state.currentQuestion.correctAnswerIndex == index;
    final wrong = state.isAnswered && selected && !correct;
    final accent = wrong
        ? colors.error
        : index.isEven
        ? colors.primary
        : colors.secondary;
    const icons = [
      Icons.shield_outlined,
      Icons.bolt_rounded,
      Icons.radar_rounded,
      Icons.lock_outline_rounded,
    ];
    return Semantics(
      button: true,
      selected: selected,
      enabled: !state.isAnswered,
      child: AnimatedScale(
        scale: wrong
            ? .97
            : selected
            ? 1.025
            : 1,
        duration: const Duration(milliseconds: 220),
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: state.isAnswered
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    state.answerQuestion(index);
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              constraints: const BoxConstraints(minHeight: 144),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: selected || correct
                    ? accent.withValues(alpha: .13)
                    : colors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected || correct ? accent : colors.outlineVariant,
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    correct
                        ? Icons.check_circle_rounded
                        : wrong
                        ? Icons.cancel_rounded
                        : icons[index % icons.length],
                    color: accent,
                    size: 28,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.currentQuestion.options[index],
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LessonFeedback extends StatelessWidget {
  const LessonFeedback({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = state.isCorrect
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withValues(alpha: .4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  state.isCorrect
                      ? 'Nice! Pertahanan naik.'
                      : 'Coba strategi lain.',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              if (state.isCorrect)
                GamePill(
                  icon: Icons.bolt_rounded,
                  text: '+20 XP',
                  color: theme.colorScheme.secondary,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            state.currentQuestion.explanation,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => state.nextQuestion(context),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              state.currentQuestionIndex ==
                          state.currentLessonQuestions.length - 1 ||
                      state.lives == 0
                  ? 'Lihat hasil misi'
                  : 'Lanjutkan',
            ),
          ),
        ],
      ),
    );
  }
}

class LessonUnavailable extends StatelessWidget {
  const LessonUnavailable({super.key, required this.loading});
  final bool loading;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Latihan')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                const CircularProgressIndicator()
              else
                Icon(
                  Icons.quiz_outlined,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
              const SizedBox(height: 20),
              Text(
                loading ? 'Menyiapkan soal…' : 'Soal belum tersedia',
                style: theme.textTheme.titleLarge,
              ),
              if (!loading) ...[
                const SizedBox(height: 12),
                Text(
                  'Kembali ke daftar level dan coba lagi.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Kembali'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
