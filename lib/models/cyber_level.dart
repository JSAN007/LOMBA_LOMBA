import 'package:flutter/material.dart';

enum LevelStatus { locked, unlocked, completed }

class CyberLevel {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  LevelStatus status;
  double progress; // 0.0 to 1.0

  CyberLevel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.status,
    this.progress = 0.0,
  });
}
