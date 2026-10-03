import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../../widgets/avatar_pickers.dart';
import 'profile_badges.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final earned = profile.badges
        .where((badge) => badge.unlocked)
        .toList(growable: false);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: profile.usesPresetAvatar
              ? AvatarGradient(presetIndex: profile.avatarPreset)
              : CircleAvatar(
                  radius: 40,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: profile.avatarUrl.isEmpty
                      ? null
                      : NetworkImage(profile.avatarUrl),
                  child: profile.avatarUrl.isEmpty
                      ? Icon(
                          Icons.person_outline_rounded,
                          size: 36,
                          color: colorScheme.primary,
                        )
                      : null,
                ),
        ),
        const SizedBox(height: 16),
        Text(
          profile.username,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          profile.bio,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        if (earned.isNotEmpty) ...[
          const SizedBox(height: 20),
          _EarnedBadgeStrip(badges: earned),
        ],
      ],
    );
  }
}

class _EarnedBadgeStrip extends StatelessWidget {
  final List<ProfileBadge> badges;

  const _EarnedBadgeStrip({required this.badges});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: badges.length == 1
          ? '1 badge unlocked'
          : '${badges.length} badges unlocked',
      child: ExcludeSemantics(
        child: SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: badges.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final badge = badges[index];
              return _EarnedBadgeChip(
                badge: badge,
                onTap: () => showBadgeDetailSheet(context, badge),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EarnedBadgeChip extends StatelessWidget {
  final ProfileBadge badge;
  final VoidCallback onTap;

  const _EarnedBadgeChip({required this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: badge.accent.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 96,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: badge.accent.withValues(alpha: 0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badge.accent.withValues(alpha: 0.22),
                  border: Border.all(
                    color: badge.accent.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Icon(badge.icon, size: 16, color: badge.accent),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  badge.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
