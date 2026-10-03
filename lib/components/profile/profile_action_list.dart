import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/account_service.dart';
import '../../state/app_state_provider.dart';

import '../../screens/edit_profile/edit_profile_screen.dart';
import '../../screens/help/help_support_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../widgets/app_snack_bar.dart';

class ProfileActionList extends StatelessWidget {
  const ProfileActionList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
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
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.logout_rounded,
            title: AppStateProvider.of(context).isSigningOut
                ? 'Menyimpan progres…'
                : 'Keluar dari akun',
            subtitle: 'Sampai jumpa di sesi belajar berikutnya',
            onTap: () async {
              final state = AppStateProvider.of(context);
              try {
                await state.signOut(AccountService.auth.signOut);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Progres belum tersimpan. Periksa koneksi lalu coba keluar lagi.',
                      ),
                    ),
                  );
                }
              }
            },
          ),
          _ActionTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update avatar, bio & info',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          _ActionTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Appearance & preferences',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          _HelpSupportTile(colorScheme: colorScheme),
        ],
      ),
    );
  }
}

/// Help & Support expands in place to reveal the admin and developer contact
/// channels, so a single tap answers "who do I email?" without leaving Profile.
class _HelpSupportTile extends StatefulWidget {
  final ColorScheme colorScheme;

  const _HelpSupportTile({required this.colorScheme});

  @override
  State<_HelpSupportTile> createState() => _HelpSupportTileState();
}

class _HelpSupportTileState extends State<_HelpSupportTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionTile(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Contact admin, developer & FAQs',
          onTap: () => setState(() => _expanded = !_expanded),
          trailing: AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      for (var i = 0; i < kSupportContacts.length; i++) ...[
                        _SupportRow(
                          contact: kSupportContacts[i],
                          onTap: () => _openSupport(context, i),
                        ),
                        if (i != kSupportContacts.length - 1)
                          const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HelpSupportScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: const Text('Lihat semua & FAQs'),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _openSupport(BuildContext context, int index) {
    final contact = kSupportContacts[index];
    Clipboard.setData(ClipboardData(text: contact.email));
    showAppSnackBar(
      context,
      'Email ${contact.label} disalin: ${contact.email}',
      icon: Icons.copy_rounded,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.8,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(icon, size: 20, color: colorScheme.onSurface),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
/// One contact channel inside the expanded Help & Support panel.
class _SupportRow extends StatelessWidget {
  final SupportContact contact;
  final VoidCallback onTap;

  const _SupportRow({required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: contact.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(contact.icon, size: 18, color: contact.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.label,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contact.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.copy_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
