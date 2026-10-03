import 'package:flutter/material.dart';

import '../core/theme/cyber_colors.dart';
import '../models/cyber_level.dart';

/// Data awal level yang tampil di Home.
List<CyberLevel> buildInitialLevels() => [
  CyberLevel(
    id: 1,
    title: "Awam",
    subtitle: "Dasar dunia digital · Level 1–10",
    icon: Icons.alternate_email_rounded,
    color: CyberColors.accentGreen,
    status: LevelStatus.unlocked,
  ),
  CyberLevel(
    id: 2,
    title: "Dasar",
    subtitle: "Kebiasaan digital aman · Level 11–20",
    icon: Icons.vpn_key_rounded,
    color: CyberColors.accentOrange,
    status: LevelStatus.unlocked,
  ),
  CyberLevel(
    id: 3,
    title: "Menengah",
    subtitle: "Kenali dan tangkal ancaman · Level 21–30",
    icon: Icons.people_outline_rounded,
    color: CyberColors.secondary,
    status: LevelStatus.unlocked,
    progress: 0.0,
  ),
  CyberLevel(
    id: 4,
    title: "Lanjutan",
    subtitle: "Perkuat pertahanan digital · Level 31–40",
    icon: Icons.phonelink_lock_rounded,
    color: CyberColors.primary,
    status: LevelStatus.unlocked,
    progress: 0.0,
  ),
  CyberLevel(
    id: 5,
    title: "Pro",
    subtitle: "Kuasai keamanan siber · Level 41–50",
    icon: Icons.workspace_premium_rounded,
    color: CyberColors.accentYellow,
    status: LevelStatus.unlocked,
  ),
];
