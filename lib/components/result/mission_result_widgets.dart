import 'package:flutter/material.dart';

class MissionResultHero extends StatelessWidget {
  const MissionResultHero({super.key, required this.success});
  final bool success;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: .65, end: 1),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeOutBack,
          builder: (context, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  colors.primary.withValues(alpha: .18),
                  colors.secondary.withValues(alpha: .2),
                ],
              ),
            ),
            child: Icon(
              success
                  ? Icons.emoji_events_rounded
                  : Icons.health_and_safety_rounded,
              size: 90,
              color: success ? colors.primary : colors.error,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          success ? 'Misi ditaklukkan!' : 'Perisaimu butuh recharge.',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          success
              ? 'Satu langkah lagi jadi penjaga dunia digital.'
              : 'Setiap percobaan bikin kamu lebih jago. Yuk, coba lagi!',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class MissionResultStats extends StatelessWidget {
  const MissionResultStats({
    super.key,
    required this.xp,
    required this.score,
    required this.total,
  });
  final int xp, score, total;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ResultStat(
              icon: Icons.bolt_rounded,
              label: 'XP didapat',
              value: '+$xp',
            ),
          ),
          Expanded(
            child: _ResultStat(
              icon: Icons.shield_rounded,
              label: 'Ancaman dihalau',
              value: '$score / $total',
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.secondary),
        const SizedBox(height: 10),
        Text(value, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
