import 'package:flutter/material.dart';

import '../motion/app_motion.dart';

/// Animated progress bar that fills from 0 to [value] (0.0 - 1.0).
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 8,
    this.borderRadius,
    this.duration,
    this.showGlow = true,
  });

  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final double? borderRadius;
  final Duration? duration;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    final fillColor = color ?? palette.primary;
    final bgColor = backgroundColor ?? palette.surfaceContainerHighest;
    final radius = borderRadius != null
        ? BorderRadius.circular(borderRadius!)
        : BorderRadius.circular(height / 2);

    final clamped = value.clamp(0.0, 1.0);
    final dur = duration ?? AppMotion.progressFill;

    if (AppMotion.reduceAnimations(context)) {
      return Container(
        height: height,
        decoration: BoxDecoration(color: bgColor, borderRadius: radius),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: clamped,
          child: Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: radius,
              boxShadow: showGlow
                  ? [
                      BoxShadow(
                        color: fillColor.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: clamped),
      duration: dur,
      curve: AppMotion.standard,
      builder: (context, v, child) {
        return Container(
          height: height,
          decoration: BoxDecoration(color: bgColor, borderRadius: radius),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: v,
            child: Container(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: radius,
                boxShadow: showGlow
                    ? [
                        BoxShadow(
                          color: fillColor.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
