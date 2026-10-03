import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motion/app_motion.dart';
import 'count_up_text.dart';

class AnimatedProgressRing extends StatelessWidget {
  const AnimatedProgressRing({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.size = 64,
    this.strokeWidth = 6,
    this.duration,
    this.showLabel = true,
    this.labelStyle,
  });

  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double strokeWidth;
  final Duration? duration;
  final bool showLabel;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).colorScheme;
    final ringColor = color ?? palette.primary;
    final bgColor = backgroundColor ?? palette.surfaceContainerHighest;
    final clamped = value.clamp(0.0, 1.0);
    final dur = duration ?? AppMotion.progressFill;

    Widget ring(double progress) {
      return CustomPaint(
        size: Size(size, size),
        painter: _RingPainter(
          progress: progress,
          color: ringColor,
          backgroundColor: bgColor,
          strokeWidth: strokeWidth,
        ),
      );
    }

    if (AppMotion.reduceAnimations(context)) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ring(clamped),
            if (showLabel)
              CountUpText(
                value: clamped * 100,
                from: 0,
                duration: Duration.zero,
                formatter: CountUpFormatters.percent,
                style: labelStyle,
              ),
          ],
        ),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: clamped),
      duration: dur,
      curve: AppMotion.standard,
      builder: (context, v, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ring(v),
              if (showLabel)
                CountUpText(
                  value: v * 100,
                  from: 0,
                  duration: dur,
                  formatter: CountUpFormatters.percent,
                  style: labelStyle,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * math.pi,
      false,
      bgPaint,
    );

    // Progress ring
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
