import 'package:flutter/material.dart';

import '../../components/settings/settings_section.dart';
import '../../core/theme/cyber_colors.dart';
import '../../state/theme_provider.dart';

/// Preferences screen. Currently hosts the light/dark appearance toggle.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.cyber;
    final controller = ThemeProvider.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Settings'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            SettingsSection(
              title: 'Appearance',
              subtitle: 'Pilih tampilan aplikasi. Perubahan langsung diterapkan.',
              children: [
                SwitchListTile.adaptive(
                  key: const Key('dark-mode-switch'),
                  value: controller.isDarkMode,
                  onChanged: (_) => controller.toggle(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  secondary: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                    child: Icon(
                      controller.isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      key: ValueKey(controller.isDarkMode),
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Dark Mode',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    controller.isDarkMode
                        ? 'Tampilan gelap aktif'
                        : 'Tampilan terang aktif',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _PalettePreview(isDark: controller.isDarkMode),
            const SizedBox(height: 24),

            SettingsSection(
              title: 'About',
              children: [
                _InfoRow(
                  icon: Icons.security_rounded,
                  label: 'SecuriGo',
                  value: '1.0.0',
                ),
                Divider(height: 1, indent: 68, endIndent: 20),
                _InfoRow(
                  icon: Icons.palette_outlined,
                  label: 'Theme preference',
                  value: 'Session only',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the live colour roles of the active theme so the toggle has a
/// visible result beyond the background itself.
class _PalettePreview extends StatelessWidget {
  final bool isDark;

  const _PalettePreview({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.cyber;

    final swatches = <(String, Color)>[
      ('Background', palette.background),
      ('Surface', palette.surface),
      ('Text', palette.textPrimary),
      ('Muted', palette.textMuted),
      ('Accent', CyberColors.primary),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isDark ? 'Dark palette' : 'Light palette',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '${swatches.length} roles',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < swatches.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 44,
                        decoration: BoxDecoration(
                          color: swatches[i].$2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: palette.border),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        swatches[i].$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, size: 18, color: colorScheme.onSurface),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: theme.textTheme.bodyLarge),
          ),
          Text(value, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}