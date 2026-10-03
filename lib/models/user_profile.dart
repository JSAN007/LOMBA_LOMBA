import 'package:flutter/material.dart';

import '../core/theme/cyber_colors.dart';

class ProfileBadge {
  final String name;
  final String tier;
  final String description;
  final String requirement;
  final int levelRequired;
  final IconData icon;
  final Color accent;
  final String assetPath;
  final bool unlocked;

  const ProfileBadge({
    required this.name,
    required this.tier,
    required this.description,
    required this.requirement,
    required this.levelRequired,
    required this.icon,
    required this.accent,
    this.assetPath = '',
    this.unlocked = false,
  });
}

class UserProfile {
  final String id;
  final String username;
  final String avatarUrl;
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

  /// Index into `kAvatarPresets`. Negative means "use [avatarUrl] instead".
  final int avatarPreset;

  const UserProfile({
    required this.id,
    required this.username,
    required this.avatarUrl,
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
    this.avatarPreset = -1,
  });

  bool get usesPresetAvatar => avatarPreset >= 0;

  UserProfile copyWith({
    String? id,
    String? username,
    String? bio,
    String? avatarUrl,
    int? avatarPreset,
    int? level,
    double? xpCurrent,
    double? xpToNext,
    int? globalRank,
    int? totalMatches,
    int? wins,
    double? winRate,
    int? totalPoints,
    List<ProfileBadge>? badges,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      level: level ?? this.level,
      xpCurrent: xpCurrent ?? this.xpCurrent,
      xpToNext: xpToNext ?? this.xpToNext,
      globalRank: globalRank ?? this.globalRank,
      totalMatches: totalMatches ?? this.totalMatches,
      wins: wins ?? this.wins,
      winRate: winRate ?? this.winRate,
      totalPoints: totalPoints ?? this.totalPoints,
      badges: badges ?? this.badges,
      avatarPreset: avatarPreset ?? this.avatarPreset,
    );
  }

  double get xpProgress =>
      xpToNext <= 0 ? 1.0 : (xpCurrent / xpToNext).clamp(0.0, 1.0);

  double badgeProgress(ProfileBadge badge) {
    final bandStart = badge.levelRequired - 9;
    final completed = (level - bandStart + 1).clamp(0, 10);
    return completed / 10;
  }

  factory UserProfile.account({
    required String id,
    required String username,
    int level = 1,
    int totalXp = 0,
    int totalLessons = 0,
    int successfulLessons = 0,
  }) {
    return UserProfile(
      id: id,
      username: username,
      avatarUrl: '',
      bio: 'Belajar lebih aman, satu langkah setiap hari.',
      level: level,
      xpCurrent: (totalXp % 100).toDouble(),
      xpToNext: 100,
      globalRank: 0,
      totalMatches: totalLessons,
      wins: successfulLessons,
      winRate: totalLessons == 0 ? 0 : successfulLessons / totalLessons * 100,
      totalPoints: totalXp,
      badges: buildBadges(currentLevel: level),
      avatarPreset: 0,
    );
  }

  factory UserProfile.dummy() {
    return UserProfile(
      id: 'u_001',
      username: 'CyberNusa',
      avatarUrl: 'https://i.pravatar.cc/300?img=68',
      bio: 'Grinding hard. Play clean. Climb the ranks.',
      level: 27,
      xpCurrent: 860,
      xpToNext: 1200,
      globalRank: 142,
      totalMatches: 248,
      wins: 156,
      winRate: (156 / 248) * 100,
      totalPoints: 48250,
      badges: buildBadges(),
      avatarPreset: 0,
    );
  }
}

List<ProfileBadge> buildBadges({int currentLevel = 27}) {
  final definitions = <ProfileBadge>[
    const ProfileBadge(
      name: 'First Blood',
      tier: 'Bronze',
      description:
          'Selesaikan 10 level pertama dan kuasai dasar deteksi phishing.',
      requirement: 'Clear levels 1 - 10',
      levelRequired: 10,
      icon: Icons.visibility_rounded,
      accent: CyberColors.accentOrange,
    ),
    const ProfileBadge(
      name: 'Signal Hunter',
      tier: 'Silver',
      description:
          'Naik ke level 20 dan selesaikan semua latihan di setiap level yang terbuka.',
      requirement: 'Clear levels 11 - 20',
      levelRequired: 20,
      icon: Icons.radar_rounded,
      accent: CyberColors.rankSilver,
    ),
    const ProfileBadge(
      name: 'Firewall Knight',
      tier: 'Gold',
      description:
          'Capai level 30 dan habiskan seluruh bank soal phishing dengan skor minimal.',
      requirement: 'Clear levels 21 - 30',
      levelRequired: 30,
      icon: Icons.shield_moon_rounded,
      accent: CyberColors.rankGold,
    ),
    const ProfileBadge(
      name: 'Zero Day Ace',
      tier: 'Platinum',
      description:
          'Tembus level 40 tanpa gagal satu pun di level 31 sampai 40.',
      requirement: 'Clear levels 31 - 40',
      levelRequired: 40,
      icon: Icons.bolt_rounded,
      accent: CyberColors.secondary,
    ),
    const ProfileBadge(
      name: 'Legend of Cyberspace',
      tier: 'Diamond',
      description:
          'Tuntaskan 50 level dan selesaikan semua latihan yang tersisa.',
      requirement: 'Clear levels 41 - 50',
      levelRequired: 50,
      icon: Icons.workspace_premium_rounded,
      accent: CyberColors.primary,
    ),
  ];

  return [
    for (final badge in definitions)
      ProfileBadge(
        name: badge.name,
        tier: badge.tier,
        description: badge.description,
        requirement: badge.requirement,
        levelRequired: badge.levelRequired,
        icon: badge.icon,
        accent: badge.accent,
        assetPath: badge.assetPath,
        unlocked: currentLevel >= badge.levelRequired,
      ),
  ];
}
