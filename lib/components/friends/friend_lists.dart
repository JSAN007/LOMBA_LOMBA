import 'package:flutter/material.dart';
import '../../services/friend_network.dart';
import '../../services/friends_service.dart';
import 'friends_widgets.dart';

class FriendLists extends StatelessWidget {
  const FriendLists({
    super.key,
    required this.links,
    required this.uid,
    required this.busy,
    required this.onAccept,
    required this.onRemove,
  });
  final List<FriendLink> links;
  final String uid;
  final Set<String> busy;
  final void Function(FriendLink) onAccept, onRemove;
  @override
  Widget build(BuildContext context) {
    final accepted = links.where((link) => link.accepted).toList();
    final incoming = links
        .where((link) => !link.accepted && link.recipient == uid)
        .toList();
    final outgoing = links
        .where((link) => !link.accepted && link.sender == uid)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (incoming.isNotEmpty) ...[
          Text(
            'Permintaan masuk · ${incoming.length}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...incoming.map((link) => _tile(link, incoming: true)),
          const SizedBox(height: 20),
        ],
        Text(
          'Temanmu · ${accepted.length}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (accepted.isEmpty)
          Text(
            'Cari pemain dan kirim permintaan untuk mulai berteman.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ...accepted.map((link) => _tile(link)),
        if (outgoing.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Menunggu balasan · ${outgoing.length}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...outgoing.map((link) => _tile(link)),
        ],
      ],
    );
  }

  Widget _tile(FriendLink link, {bool incoming = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      PlayerCard(
        player: PlayerSummary(id: link.otherId(uid), name: link.otherName(uid)),
      ),
      Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        children: [
          if (incoming)
            FilledButton(
              onPressed: busy.contains(link.otherId(uid))
                  ? null
                  : () => onAccept(link),
              child: const Text('Terima'),
            ),
          TextButton(
            onPressed: busy.contains(link.otherId(uid))
                ? null
                : () => onRemove(link),
            child: Text(
              incoming
                  ? 'Tolak'
                  : link.accepted
                  ? 'Hapus teman'
                  : 'Batalkan',
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
    ],
  );
}
