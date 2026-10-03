import 'package:flutter/material.dart';

class PracticeTabs extends StatelessWidget {
  const PracticeTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            dividerHeight: 0,
            indicator: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            labelColor: theme.colorScheme.onPrimaryContainer,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            tabs: const [
              Tab(text: 'Pilihan ganda'),
              Tab(text: 'Naratif'),
            ],
          ),
        ),
      ),
    );
  }
}
