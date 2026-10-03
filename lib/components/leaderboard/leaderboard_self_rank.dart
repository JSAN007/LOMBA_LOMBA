import 'package:flutter/material.dart';
import '../../models/leaderboard_entry.dart';

class LeaderboardSelfRank extends StatelessWidget {
  final LeaderboardEntry currentUser;

  const LeaderboardSelfRank({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // The label and rank share one elastic text so the pill can shrink
          // on a narrow phone instead of overflowing.
          Flexible(
            child: Text(
              'Kamu ada di #${currentUser.rank}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Hero(
            tag: 'profile_avatar_self_${currentUser.userId}',
            child: CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.surface,
              backgroundImage: NetworkImage(currentUser.avatarUrl),
              onBackgroundImageError: (_, _) {},
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              currentUser.username,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onPrimaryContainer,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_formatPoints(currentUser.points)} pts',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPoints(int points) {
    if (points >= 1000000) {
      return '${(points / 1000000).toStringAsFixed(1)}M';
    }
    if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(0)}K';
    }
    return points.toString();
  }
}
