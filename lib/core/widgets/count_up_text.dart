import 'package:flutter/material.dart';

import '../motion/app_motion.dart';

typedef CountUpFormatter = String Function(num value);

/// Animated number counter.
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    this.from = 0,
    this.duration,
    this.formatter,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final num value;
  final num from;
  final Duration? duration;
  final CountUpFormatter? formatter;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final dur = duration ?? AppMotion.countUp;
    final target = value.toDouble();

    if (AppMotion.reduceAnimations(context)) {
      final formatted = formatter?.call(value) ?? value.toString();
      return Text(
        formatted,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: from.toDouble(), end: target),
      duration: dur,
      curve: AppMotion.standard,
      builder: (context, val, child) {
        final formatted = formatter?.call(val) ?? val.toStringAsFixed(0);
        return Text(
          formatted,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

/// Common formatters.
class CountUpFormatters {
  const CountUpFormatters._();

  static String integer(num value) {
    // Remove decimals for integers
    final rounded = value.round();
    return rounded.toString();
  }

  static String compact(num value) {
    final v = value.round();
    if (v >= 1000000) {
      return '${(v / 1000000.0).toStringAsFixed(v % 1000000 == 0 ? 0 : 1)}M';
    }
    if (v >= 1000) {
      return '${(v / 1000.0).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}K';
    }
    return v.toString();
  }

  static String percent(num value) {
    // value is 0-100 or 0-1? assume 0-100 if >1, else *100
    final pct = value > 1.0 ? value.roundToDouble() : (value * 100.0);
    return '${pct.toStringAsFixed(pct % 1 == 0 ? 0 : 1)}%';
  }

  static String points(num value) {
    return '${value.round()} pts';
  }

  static String winsMatches(int wins, int matches) {
    return '$wins W / $matches M';
  }
}
