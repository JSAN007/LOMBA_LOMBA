import 'package:flutter/material.dart';

import '../../core/theme/cyber_colors.dart';
import '../../models/leaderboard_entry.dart';

class LeaderboardPodiumItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final int tier;
  final double height;

  const LeaderboardPodiumItem({
    super.key,
    required this.entry,
    required this.tier,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final (podiumColor, glowOpacity, crownIcon) = switch (tier) {
      1 => (CyberColors.rankGold, 0.16, Icons.emoji_events_rounded),
      2 => (CyberColors.rankSilver, 0.12, Icons.military_tech_outlined),
      3 => (CyberColors.rankBronze, 0.10, Icons.shield_outlined),
      _ => (colorScheme.primary, 0.10, Icons.emoji_events_outlined),
    };

    return Flexible(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: podiumColor.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: podiumColor.withValues(alpha: glowOpacity),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: podiumColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: podiumColor.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Hero(
                      tag: entry.isCurrentUser
                          ? 'profile_avatar_self_${entry.userId}'
                          : 'lb_avatar_${entry.userId}_$tier',
                      child: CircleAvatar(
                        radius: tier == 1 ? 26 : 23,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        backgroundImage: entry.avatarUrl.isEmpty
                            ? null
                            : NetworkImage(entry.avatarUrl),
                        child: entry.avatarUrl.isEmpty
                            ? Icon(
                                Icons.person_outline_rounded,
                                color: colorScheme.primary,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(crownIcon, size: 16, color: podiumColor),
                      const SizedBox(width: 4),
                      Text(
                        '#${entry.rank}',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: podiumColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    entry.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatPoints(entry.points)} pts',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.wins}W / ${entry.matches}M',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPoints(int points) {
    if (points >= 1000000) {
      return '${(points / 1000000).toStringAsFixed(1)}M';
    }
    if (points >= 1000) return '${(points / 1000).toStringAsFixed(0)}K';
    return points.toString();
  }
}
