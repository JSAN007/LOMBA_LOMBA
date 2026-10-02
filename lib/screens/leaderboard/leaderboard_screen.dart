import 'package:flutter/material.dart';
import '../../models/leaderboard_entry.dart';
import '../../components/leaderboard/leaderboard_podium.dart';
import '../../components/leaderboard/leaderboard_list.dart';
import '../../components/leaderboard/leaderboard_self_rank.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({
    super.key,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final List<LeaderboardEntry> _allEntries = LeaderboardEntry.dummyTopList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  List<LeaderboardEntry> get _top3 {
    final sorted = List<LeaderboardEntry>.from(_allEntries)
      ..sort((a, b) => a.rank.compareTo(b.rank));
    if (sorted.length >= 3) {
      return sorted.sublist(0, 3);
    }
    return List<LeaderboardEntry>.from(sorted);
  }

  List<LeaderboardEntry> get _restList {
    final sorted = List<LeaderboardEntry>.from(_allEntries)
      ..sort((a, b) => a.rank.compareTo(b.rank));
    if (sorted.length <= 3) {
      return List<LeaderboardEntry>.from(sorted);
    }
    return sorted.sublist(3);
  }

  LeaderboardEntry? get _currentUser {
    for (final e in _allEntries) {
      if (e.isCurrentUser) {
        return e;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final currentUser = _currentUser;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
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
            const SizedBox(height: 20),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLeaderboardListView(),
                      _buildLeaderboardListView(),
                      _buildLeaderboardListView(),
                    ],
                  ),
                ),
              ),
            ),
            if (currentUser != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: LeaderboardSelfRank(currentUser: currentUser),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardListView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          LeaderboardPodium(top3: _top3),
          const SizedBox(height: 16),
          LeaderboardList(entries: _restList),
          const SizedBox(height: 88),
        ],
      ),
    );
  }
}