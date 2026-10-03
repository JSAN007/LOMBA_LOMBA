import 'package:flutter/material.dart';

import '../core/theme/cyber_colors.dart';

class AvatarPreset {
  final String name;
  final List<Color> gradient;

  const AvatarPreset({required this.name, required this.gradient});
}

const List<AvatarPreset> kAvatarPresets = [
  AvatarPreset(
    name: 'Mint',
    gradient: [CyberColors.accentGreen, CyberColors.primary],
  ),
  AvatarPreset(
    name: 'Ocean',
    gradient: [CyberColors.primary, CyberColors.secondary],
  ),
  AvatarPreset(
    name: 'Lilac',
    gradient: [CyberColors.secondary, CyberColors.rankSilver],
  ),
  AvatarPreset(
    name: 'Sunset',
    gradient: [CyberColors.accentOrange, CyberColors.rankBronze],
  ),
  AvatarPreset(
    name: 'Gold',
    gradient: [CyberColors.rankGold, CyberColors.accentOrange],
  ),
  AvatarPreset(
    name: 'Rose',
    gradient: [CyberColors.accentRed, CyberColors.secondary],
  ),
  AvatarPreset(
    name: 'Jade',
    gradient: [CyberColors.accentGreen, CyberColors.secondary],
  ),
  AvatarPreset(
    name: 'Cobalt',
    gradient: [Color(0xFF4A6FA5), CyberColors.secondary],
  ),
  AvatarPreset(
    name: 'Amber',
    gradient: [CyberColors.rankBronze, CyberColors.rankGold],
  ),
  AvatarPreset(
    name: 'Violet',
    gradient: [CyberColors.secondary, CyberColors.primary],
  ),
  AvatarPreset(
    name: 'Aqua',
    gradient: [CyberColors.primary, CyberColors.accentGreen],
  ),
  AvatarPreset(
    name: 'Coral',
    gradient: [CyberColors.accentRed, CyberColors.accentOrange],
  ),
];

List<Color> avatarGradient(int index) {
  if (index < 0 || index >= kAvatarPresets.length) {
    return kAvatarPresets.first.gradient;
  }
  return kAvatarPresets[index].gradient;
}

String avatarPresetName(int index) {
  if (index < 0 || index >= kAvatarPresets.length) {
    return kAvatarPresets.first.name;
  }
  return kAvatarPresets[index].name;
}
