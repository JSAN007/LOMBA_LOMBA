import 'package:flutter/material.dart';
import '../../models/leaderboard_entry.dart';
import 'leaderboard_podium_item.dart';

class LeaderboardPodium extends StatelessWidget {
  final List<LeaderboardEntry> top3;

  const LeaderboardPodium({
    super.key,
    required this.top3,
  });

  @override
  Widget build(BuildContext context) {
    if (top3.isEmpty) {
      return const SizedBox.shrink();
    }

    final first = top3.isNotEmpty ? top3[0] : null;
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (second != null)
            LeaderboardPodiumItem(
              entry: second,
              tier: 2,
              height: 164,
            ),
          if (first != null)
            LeaderboardPodiumItem(
              entry: first,
              tier: 1,
              height: 192,
            ),
          if (third != null)
            LeaderboardPodiumItem(
              entry: third,
              tier: 3,
              height: 156,
            ),
        ],
      ),
    );
  }
}