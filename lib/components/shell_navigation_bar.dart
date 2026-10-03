import 'package:flutter/material.dart';
import '../widgets/glass_nav_bar.dart';
import 'auth/progress_sync_notice.dart';

class ShellNavigationBar extends StatelessWidget {
  const ShellNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const ProgressSyncNotice(),
      GlassNavBar(currentIndex: currentIndex, onTap: onTap),
    ],
  );
}
