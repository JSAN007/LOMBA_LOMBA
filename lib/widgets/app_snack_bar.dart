import 'package:flutter/material.dart';

import '../core/theme/cyber_colors.dart';

/// The app's content column width, mirrored from [ResponsiveLayoutWrapper].
const double kAppColumnMaxWidth = 480;

/// Shows a snackbar that hugs the app's content column instead of spanning
/// the whole window.
///
/// `ScaffoldMessenger` is created by `MaterialApp`, above
/// `ResponsiveLayoutWrapper`, so a plain `SnackBar` stretches across the full
/// screen width even though the UI itself is capped at
/// [kAppColumnMaxWidth]. Passing an explicit [SnackBar.width] pins it back to
/// the column — it only applies with [SnackBarBehavior.floating], which the
/// theme sets.
void showAppSnackBar(
  BuildContext context,
  String message, {
  IconData? icon,
  Duration duration = const Duration(seconds: 4),
}) {
  final mediaQuery = MediaQuery.of(context);
  final horizontalInset = 16.0;

  // Never wider than the app column, and never wider than the window minus
  // the same inset used on the rest of the layout.
  final available = mediaQuery.size.width - (horizontalInset * 2);
  final width = available.clamp(0.0, kAppColumnMaxWidth - horizontalInset * 2);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        width: width,
        duration: duration,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 10),
            ],
            Flexible(child: Text(message)),
          ],
        ),
      ),
    );
}

/// Convenience wrapper matching the app's own palette when a snackbar needs
/// a custom action or layout.
class AppSnackBar extends StatelessWidget {
  final String message;
  final IconData? icon;

  const AppSnackBar({super.key, required this.message, this.icon});

  @override
  Widget build(BuildContext context) {
    final palette = context.cyber;

    return SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: palette.background),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(message, style: TextStyle(color: palette.background)),
          ),
        ],
      ),
    );
  }
}
