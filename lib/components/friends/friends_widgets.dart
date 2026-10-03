import 'package:flutter/material.dart';
import '../../services/friends_service.dart';

class FriendsIntro extends StatelessWidget {
  const FriendsIntro({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: .15),
            theme.colorScheme.secondary.withValues(alpha: .18),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.people_alt_rounded,
            size: 40,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            'Lebih seru\nbareng teman.',
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Temukan sesama pemain SecuriGo. Cari dengan bagian awal nama mereka.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class FriendsMessage extends StatelessWidget {
  const FriendsMessage({
    super.key,
    required this.title,
    required this.description,
    this.retry,
  });
  final String title, description;
  final VoidCallback? retry;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
      child: Column(
        children: [
          Icon(
            Icons.travel_explore_rounded,
            size: 48,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (retry != null)
            TextButton(onPressed: retry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}

class PlayerCard extends StatelessWidget {
  const PlayerCard({super.key, required this.player, this.action});
  final PlayerSummary player;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = player.name.trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondary.withValues(alpha: .18),
          child: Text(
            name.isEmpty ? '?' : name.characters.first.toUpperCase(),
            style: theme.textTheme.titleLarge,
          ),
        ),
        title: Text(
          player.name,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          player.isCurrentUser ? 'Kamu · Pemain SecuriGo' : 'Pemain SecuriGo',
          style: theme.textTheme.bodyMedium,
        ),
        trailing:
            action ??
            Icon(Icons.shield_outlined, color: theme.colorScheme.primary),
      ),
    );
  }
}
