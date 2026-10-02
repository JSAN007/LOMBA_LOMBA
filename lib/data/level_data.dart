import 'package:flutter/material.dart';

import '../core/theme/cyber_colors.dart';
import '../models/cyber_level.dart';

/// Data awal level yang tampil di Home.
List<CyberLevel> buildInitialLevels() => [
  CyberLevel(
    id: 1,
    title: "Deteksi Phishing",
    subtitle: "Kenali email palsu berbahaya",
    icon: Icons.alternate_email_rounded,
    color: CyberColors.accentGreen,
    status: LevelStatus.completed,
    progress: 1.0,
  ),
  CyberLevel(
    id: 2,
    title: "Password Mastery",
    subtitle: "Buat kata sandi anti retas",
    icon: Icons.vpn_key_rounded,
    color: CyberColors.accentOrange,
    status: LevelStatus.unlocked,
    progress: 0.75,
  ),
  CyberLevel(
    id: 3,
    title: "Social Engineering",
    subtitle: "Waspada manipulasi psikologis",
    icon: Icons.people_outline_rounded,
    color: CyberColors.secondary,
    status: LevelStatus.locked,
    progress: 0.0,
  ),
  CyberLevel(
    id: 4,
    title: "Keamanan Perangkat",
    subtitle: "Proteksi gadget dari malware",
    icon: Icons.phonelink_lock_rounded,
    color: CyberColors.primary,
    status: LevelStatus.locked,
    progress: 0.0,
  ),
];
