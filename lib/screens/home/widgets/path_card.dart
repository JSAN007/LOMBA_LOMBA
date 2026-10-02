import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/cyber_colors.dart';
import '../../../models/cyber_level.dart';
import '../../../widgets/circular_progress_widget.dart';

class PathCard extends StatelessWidget {
  final CyberLevel level;
  final VoidCallback onTap;

  const PathCard({
    super.key,
    required this.level,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.cyber;
    final isLocked = level.status == LevelStatus.locked;
    final isCompleted = level.status == LevelStatus.completed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isLocked ? palette.border : level.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isLocked
                    ? palette.surfaceAlt
                    : level.color.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Icon(
                  isLocked ? Icons.lock_outline_rounded : level.icon,
                  color: isLocked ? palette.textMuted : level.color,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Title & subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isLocked ? palette.textMuted : palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    level.subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Progress circle
            if (!isLocked)
              CircularProgressWidget(
                progress: level.progress,
                color: isCompleted ? CyberColors.accentGreen : level.color,
                size: 42,
                strokeWidth: 3.5,
              ),
            if (isLocked)
              Icon(
                Icons.chevron_right_rounded,
                color: palette.textMuted,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
