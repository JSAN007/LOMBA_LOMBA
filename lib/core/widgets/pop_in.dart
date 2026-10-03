import 'package:flutter/material.dart';

import '../motion/app_motion.dart';

/// Pop in animation (scale + fade) with easeOutBack.
class PopIn extends StatefulWidget {
  const PopIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration,
    this.curve,
  });

  final Widget child;
  final Duration delay;
  final Duration? duration;
  final Curve? curve;

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    final entrance = widget.duration ?? AppMotion.base;
    final total = widget.delay + entrance;

    _controller = AnimationController(vsync: this, duration: total);

    // The delay lives inside the controller as a leading hold, so no Timer is
    // needed and nothing outlives the widget tree.
    final start = total == Duration.zero
        ? 1.0
        : widget.delay.inMicroseconds / total.inMicroseconds;

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1.0, curve: widget.curve ?? AppMotion.standard),
    );

    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, 1.0, curve: widget.curve ?? AppMotion.pop),
      ),
    );
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
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
