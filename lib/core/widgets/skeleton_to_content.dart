import 'package:flutter/material.dart';

import '../motion/app_motion.dart';

/// Crossfade between skeleton and content.
class SkeletonToContent extends StatelessWidget {
  const SkeletonToContent({
    super.key,
    required this.isLoading,
    required this.skeleton,
    required this.content,
    this.duration,
  });

  final bool isLoading;
  final Widget skeleton;
  final Widget content;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final dur = duration ?? AppMotion.skeletonCrossfade;
    return AnimatedSwitcher(
      duration: dur,
      transitionBuilder: (child, anim) {
        return FadeTransition(opacity: anim, child: child);
      },
      child: isLoading ? skeleton : content,
    );
  }
}
