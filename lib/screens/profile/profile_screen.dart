import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../components/profile/profile_header.dart';
import '../../components/profile/profile_xp_bar.dart';
import '../../components/profile/profile_stats_grid.dart';
import '../../components/profile/profile_badges.dart';
import '../../components/profile/profile_action_list.dart';
import '../../services/account_service.dart';

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

  UserProfile get _profile => UserProfile.account(
    id: AccountService.configured
        ? AccountService.auth.currentUser?.uid ?? ''
        : '',
    username: AccountService.configured
        ? AccountService.auth.currentUser?.displayName ?? 'Pelajar'
        : 'Pelajar',
  );

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: ProfileHeader(profile: _profile)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 64, 20, 20),
              sliver: SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileXpBar(profile: _profile),
                        const SizedBox(height: 16),
                        ProfileStatsGrid(profile: _profile),
                        const SizedBox(height: 16),
                        ProfileBadges(profile: _profile),
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
