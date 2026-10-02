class LeaderboardEntry {
  final String userId;
  final String username;
  final String avatarUrl;
  final int rank;
  final int points;
  final int wins;
  final int matches;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.rank,
    required this.points,
    required this.wins,
    required this.matches,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.dummyCurrent() => const LeaderboardEntry(
        userId: 'u_001',
        username: 'CyberNusa',
        avatarUrl: 'https://i.pravatar.cc/300?img=68',
        rank: 142,
        points: 48250,
        wins: 156,
        matches: 248,
        isCurrentUser: true,
      );

  static List<LeaderboardEntry> dummyTopList() {
    final entries = <LeaderboardEntry>[
      LeaderboardEntry(
        userId: 'u_top1',
        username: 'NovaX',
        avatarUrl: 'https://i.pravatar.cc/300?img=1',
        rank: 1,
        points: 98240,
        wins: 412,
        matches: 520,
      ),
      LeaderboardEntry(
        userId: 'u_top2',
        username: 'Aurell',
        avatarUrl: 'https://i.pravatar.cc/300?img=12',
        rank: 2,
        points: 92410,
        wins: 388,
        matches: 491,
      ),
      LeaderboardEntry(
        userId: 'u_top3',
        username: 'Ryzen',
        avatarUrl: 'https://i.pravatar.cc/300?img=21',
        rank: 3,
        points: 88650,
        wins: 362,
        matches: 460,
      ),
      LeaderboardEntry(
        userId: 'u_4',
        username: 'Flux',
        avatarUrl: 'https://i.pravatar.cc/300?img=32',
        rank: 4,
        points: 84210,
        wins: 341,
        matches: 438,
      ),
      LeaderboardEntry(
        userId: 'u_5',
        username: 'Orbit',
        avatarUrl: 'https://i.pravatar.cc/300?img=45',
        rank: 5,
        points: 80840,
        wins: 326,
        matches: 420,
      ),
      LeaderboardEntry(
        userId: 'u_6',
        username: 'Zer0',
        avatarUrl: 'https://i.pravatar.cc/300?img=56',
        rank: 6,
        points: 77200,
        wins: 308,
        matches: 402,
      ),
      LeaderboardEntry(
        userId: 'u_7',
        username: 'Skyn',
        avatarUrl: 'https://i.pravatar.cc/300?img=7',
        rank: 7,
        points: 74420,
        wins: 294,
        matches: 388,
      ),
      LeaderboardEntry(
        userId: 'u_8',
        username: 'Vex',
        avatarUrl: 'https://i.pravatar.cc/300?img=8',
        rank: 8,
        points: 71880,
        wins: 282,
        matches: 375,
      ),
      LeaderboardEntry(
        userId: 'u_9',
        username: 'Rynx',
        avatarUrl: 'https://i.pravatar.cc/300?img=9',
        rank: 9,
        points: 69240,
        wins: 268,
        matches: 362,
      ),
      LeaderboardEntry(
        userId: 'u_10',
        username: 'Neon',
        avatarUrl: 'https://i.pravatar.cc/300?img=10',
        rank: 10,
        points: 66890,
        wins: 256,
        matches: 350,
      ),
      LeaderboardEntry.dummyCurrent(),
      LeaderboardEntry(
        userId: 'u_143',
        username: 'Kairo',
        avatarUrl: 'https://i.pravatar.cc/300?img=43',
        rank: 143,
        points: 48020,
        wins: 154,
        matches: 246,
      ),
      LeaderboardEntry(
        userId: 'u_144',
        username: 'Milo',
        avatarUrl: 'https://i.pravatar.cc/300?img=44',
        rank: 144,
        points: 47850,
        wins: 153,
        matches: 245,
      ),
    ];

    entries.sort((a, b) => a.rank.compareTo(b.rank));
    return entries;
  }
}