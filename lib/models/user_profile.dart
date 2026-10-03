class ProfileBadge {
  final String name;
  final String assetPath;
  final bool unlocked;

  const ProfileBadge({
    required this.name,
    required this.assetPath,
    this.unlocked = false,
  });
}

class UserProfile {
  final String id;
  final String username;
  final String avatarUrl;
  final String coverUrl;
  final String bio;
  final int level;
  final double xpCurrent;
  final double xpToNext;
  final int globalRank;
  final int totalMatches;
  final int wins;
  final double winRate;
  final int totalPoints;
  final List<ProfileBadge> badges;

  const UserProfile({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.coverUrl,
    required this.bio,
    required this.level,
    required this.xpCurrent,
    required this.xpToNext,
    required this.globalRank,
    required this.totalMatches,
    required this.wins,
    required this.winRate,
    required this.totalPoints,
    required this.badges,
  });

  double get xpProgress =>
      xpToNext <= 0 ? 1.0 : (xpCurrent / xpToNext).clamp(0.0, 1.0);

  factory UserProfile.account({required String id, required String username}) =>
      UserProfile(
        id: id,
        username: username,
        avatarUrl: '',
        coverUrl: '',
        bio: 'Belajar lebih aman, satu langkah setiap hari.',
        level: 1,
        xpCurrent: 0,
        xpToNext: 100,
        globalRank: 0,
        totalMatches: 0,
        wins: 0,
        winRate: 0,
        totalPoints: 0,
        badges: const [],
      );

  factory UserProfile.dummy() {
    final unlockedBadges = [
      ProfileBadge(
        name: 'Rising Star',
        assetPath: 'assets/badges/rising_star.png',
        unlocked: true,
      ),
      ProfileBadge(
        name: 'Champion',
        assetPath: 'assets/badges/champion.png',
        unlocked: true,
      ),
      ProfileBadge(
        name: 'Legend',
        assetPath: 'assets/badges/legend.png',
        unlocked: false,
      ),
      ProfileBadge(
        name: 'Iron Will',
        assetPath: 'assets/badges/iron_will.png',
        unlocked: true,
      ),
    ];

    return UserProfile(
      id: 'u_001',
      username: 'CyberNusa',
      avatarUrl: 'https://i.pravatar.cc/300?img=68',
      coverUrl:
          'https://images.unsplash.com/photo-1511512578047-dfb367046420?q=80&w=1600&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      bio: 'Grinding hard. Play clean. Climb the ranks.',
      level: 27,
      xpCurrent: 860,
      xpToNext: 1200,
      globalRank: 142,
      totalMatches: 248,
      wins: 156,
      winRate: (156 / 248) * 100,
      totalPoints: 48250,
      badges: unlockedBadges,
    );
  }
}
