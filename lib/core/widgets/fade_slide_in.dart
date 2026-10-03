import 'package:flutter/material.dart';

import '../motion/app_motion.dart';

/// Fade in + slide up animation that runs once per mount.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = Duration.zero,
    this.duration,
    this.beginOffset = const Offset(0, 0.08),
    this.endOffset = Offset.zero,
    this.curve,
    this.runOnce = true,
  });

  final Widget child;
  final int index;
  final Duration delay;
  final Duration? duration;
  final Offset beginOffset;
  final Offset endOffset;
  final Curve? curve;
  final bool runOnce;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _started = false;

  @override
  void initState() {
    super.initState();

    final entrance = widget.duration ?? AppMotion.base;
    final delay =
        widget.delay +
        Duration(
          milliseconds: widget.index * AppMotion.staggerStep.inMilliseconds,
        );
    final total = delay + entrance;

    _controller = AnimationController(vsync: this, duration: total);

    // The stagger lives inside the controller as a leading hold, so no
    // Timer is needed and nothing outlives the widget tree.
    final curve = widget.curve ?? AppMotion.standard;
    final interval = Interval(
      total == Duration.zero
          ? 1.0
          : delay.inMicroseconds / total.inMicroseconds,
      1.0,
      curve: curve,
    );

    _fade = CurvedAnimation(parent: _controller, curve: interval);

    _slide = Tween<Offset>(
      begin: widget.beginOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: interval));
  }

  /// MediaQuery is not readable from initState, so the entrance waits for the
  /// first dependency pass.
  void _startAnimation() {
    if (_started) return;
    _started = true;

    if (AppMotion.reduceAnimations(context)) {
      _controller.value = 1.0;
      return;
    }

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
