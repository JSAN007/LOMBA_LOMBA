import 'package:flutter/material.dart';

import '../core/theme/cyber_colors.dart';

/// Responsive Wrapper for Desktop/Tablet displays
class ResponsiveLayoutWrapper extends StatelessWidget {
  final Widget child;
  const ResponsiveLayoutWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.cyber;

    return Scaffold(
      backgroundColor: palette.background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            border: Border.symmetric(
              vertical: BorderSide(color: palette.border, width: 1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
