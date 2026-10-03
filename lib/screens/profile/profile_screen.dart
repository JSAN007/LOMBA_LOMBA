import 'package:flutter/material.dart';

import '../../components/profile/profile_action_list.dart';
import '../../components/profile/profile_badges.dart';
import '../../components/profile/profile_header.dart';
import '../../components/profile/profile_stats_grid.dart';
import '../../components/profile/profile_xp_bar.dart';
import '../../models/user_profile.dart';
import '../../services/account_service.dart';
import '../../state/app_state_provider.dart';
import '../../state/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
        );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  UserProfile _profile(BuildContext context) {
    final controller = ProfileProvider.of(context);
    final editable = controller.profile;
    if (!AccountService.configured) return editable;

    final state = AppStateProvider.of(context);
    final user = AccountService.auth.currentUser;
    final wins = state.successfulLessons;
    final matches = state.totalLessons;
    return editable.copyWith(
      id: user?.uid ?? editable.id,
      username: controller.hasUserEdits
          ? editable.username
          : user?.displayName ?? state.username,
      level: state.level,
      xpCurrent: (state.totalXp % 100).toDouble(),
      xpToNext: 100,
      globalRank: 0,
      totalMatches: matches,
      wins: wins,
      winRate: matches == 0 ? 0 : wins / matches * 100,
      totalPoints: state.totalXp,
      badges: buildBadges(currentLevel: state.level),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = _profile(context);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 28),
                child: ProfileHeader(profile: profile),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
              sliver: SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileXpBar(profile: profile),
                        const SizedBox(height: 16),
                        ProfileStatsGrid(profile: profile),
                        const SizedBox(height: 16),
                        ProfileBadges(profile: profile),
                        const SizedBox(height: 16),
                        const ProfileActionList(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
