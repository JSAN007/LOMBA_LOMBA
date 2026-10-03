import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/cyber_colors.dart';

/// A simple shimmer skeleton placeholder.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.shape = BoxShape.rectangle,
    this.color,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;
  final Color? color;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.cyber;
    final baseColor = widget.color ?? palette.surfaceAlt;
    final highlightColor = baseColor.withValues(alpha: 0.4);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle
                ? null
                : BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2 * _controller.value, -1.0),
              end: Alignment(1.0 + 2 * _controller.value, 1.0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.25, 0.5, 0.75],
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton for card.
class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({super.key, this.height = 120, this.width = 100.0});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(width: width, height: height, borderRadius: 20);
  }
}

/// Skeleton for text line.
class AppSkeletonText extends StatelessWidget {
  const AppSkeletonText({
    super.key,
    this.width,
    this.height = 14.0,
    this.borderRadius = 8.0,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

/// Skeleton for circle/avatar.
class AppSkeletonCircle extends StatelessWidget {
  const AppSkeletonCircle({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(width: size, height: size, shape: BoxShape.circle);
  }
}
