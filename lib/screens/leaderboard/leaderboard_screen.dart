import 'package:flutter/material.dart';
import '../../models/leaderboard_entry.dart';
import '../../components/leaderboard/leaderboard_podium.dart';
import '../../components/leaderboard/leaderboard_list.dart';
import '../../components/leaderboard/leaderboard_self_rank.dart';
import '../../state/app_state_provider.dart';
import '../../state/profile_controller.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  List<LeaderboardEntry>? _demoEntries;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _demoEntries ??= LeaderboardEntry.demoOpponents(
      initialUserPoints: AppStateProvider.of(context).totalXp,
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

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
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = AppStateProvider.of(context);
    final profileController = context
        .dependOnInheritedWidgetOfExactType<ProfileProvider>()
        ?.notifier;
    final profile = profileController?.profile;
    final entries = LeaderboardEntry.rankEntries([
      ..._demoEntries!,
      LeaderboardEntry(
        userId: profile?.id ?? 'current-user',
        username: profileController?.hasUserEdits == true
            ? profile!.username
            : state.username,
        avatarUrl: profile?.avatarUrl ?? '',
        avatarPreset: profile?.avatarPreset ?? 0,
        rank: 0,
        points: state.totalXp,
        wins: state.successfulLessons,
        matches: state.totalLessons,
        isCurrentUser: true,
      ),
    ]);
    final currentUser = entries.singleWhere((entry) => entry.isCurrentUser);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: colorScheme.primaryContainer,
                  ),
                  labelColor: colorScheme.onPrimaryContainer,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  labelStyle: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Global'),
                    Tab(text: 'Weekly'),
                    Tab(text: 'Friends'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Text(
                'Demo · Lawan simulasi, XP kamu asli.\n'
                'Selesaikan latihan untuk naik peringkat.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLeaderboardListView(entries),
                      _buildLeaderboardListView(entries),
                      _buildLeaderboardListView(entries),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: LeaderboardSelfRank(currentUser: currentUser),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardListView(List<LeaderboardEntry> entries) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          LeaderboardPodium(top3: entries.take(3).toList()),
          const SizedBox(height: 16),
          LeaderboardList(entries: entries.skip(3).toList()),
          const SizedBox(height: 88),
        ],
      ),
    );
  }
}
