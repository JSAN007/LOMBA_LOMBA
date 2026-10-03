class LeaderboardEntry {
  final String userId;
  final String username;
  final String avatarUrl;
  final int avatarPreset;
  final int rank;
  final int points;
  final int wins;
  final int matches;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    this.avatarPreset = -1,
    required this.rank,
    required this.points,
    required this.wins,
    required this.matches,
    this.isCurrentUser = false,
  });

  LeaderboardEntry withRank(int rank) => LeaderboardEntry(
    userId: userId,
    username: username,
    avatarUrl: avatarUrl,
    avatarPreset: avatarPreset,
    rank: rank,
    points: points,
    wins: wins,
    matches: matches,
    isCurrentUser: isCurrentUser,
  );

  /// Capture once per screen/session: opponents must not chase earned XP.
  static List<LeaderboardEntry> demoOpponents({
    required int initialUserPoints,
  }) {
    const names = [
      'Neon',
      'Rynx',
      'Vex',
      'Skyn',
      'Zer0',
      'Orbit',
      'Flux',
      'Ryzen',
      'Aurell',
      'NovaX',
    ];
    final base = (initialUserPoints - 100).clamp(0, initialUserPoints);
    return List.generate(
      names.length,
      (index) => LeaderboardEntry(
        userId: 'demo_$index',
        username: names[index],
        avatarUrl: '',
        avatarPreset: index,
        rank: 0,
        points: base + (index + 1) * 20,
        wins: index ~/ 5,
        matches: index ~/ 5 + 1,
      ),
    );
  }

  /// Higher XP ranks first; equal XP shares rank, with stable identity order.
  static List<LeaderboardEntry> rankEntries(List<LeaderboardEntry> entries) {
    final sorted = List<LeaderboardEntry>.of(entries)
      ..sort((a, b) {
        final points = b.points.compareTo(a.points);
        return points != 0 ? points : a.userId.compareTo(b.userId);
      });
    var rank = 0;
    final ranked = <LeaderboardEntry>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i == 0 || sorted[i].points != sorted[i - 1].points) rank = i + 1;
      ranked.add(sorted[i].withRank(rank));
    }
    return ranked;
  }
}
