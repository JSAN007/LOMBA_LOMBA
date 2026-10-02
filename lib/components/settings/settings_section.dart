import 'package:flutter/material.dart';

/// Grouped card container used by the settings screen.
///
/// Keeps the 24px corner radius, hairline border and soft shadow consistent
/// with the profile cards.
class SettingsSection extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
        ],
        if (subtitle != null) ...[
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
        ] else
          const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}