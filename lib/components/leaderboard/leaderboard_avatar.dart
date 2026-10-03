import 'package:flutter/material.dart';

import '../../models/leaderboard_entry.dart';
import '../../widgets/avatar_pickers.dart';

class LeaderboardAvatar extends StatelessWidget {
  const LeaderboardAvatar({
    super.key,
    required this.entry,
    required this.radius,
  });

  final LeaderboardEntry entry;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (entry.avatarPreset >= 0) {
      return SizedBox.square(
        dimension: radius * 2,
        child: FittedBox(
          child: AvatarGradient(presetIndex: entry.avatarPreset),
        ),
      );
    }
    final colors = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.surfaceContainerHighest,
      backgroundImage: entry.avatarUrl.isEmpty
          ? null
          : NetworkImage(entry.avatarUrl),
      onBackgroundImageError: entry.avatarUrl.isEmpty ? null : (_, _) {},
      child: entry.avatarUrl.isEmpty
          ? Icon(
              Icons.person_outline_rounded,
              color: colors.primary,
              size: radius,
            )
          : null,
    );
  }
}
