import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../components/friends/friends_widgets.dart';
import '../../services/friends_service.dart';
import '../../services/account_service.dart';
import '../../services/friend_network.dart';
import '../../components/friends/friend_lists.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key, this.search, this.network});
  final PlayerSearch? search;
  final FriendNetwork? network;
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _controller = TextEditingController();
  late final PlayerSearch _search = widget.search ?? FriendsService();
  Timer? _debounce;
  int _request = 0;
  bool _loading = false;
  bool _searched = false;
  List<PlayerSummary> _players = [];
  String? _error;
  late final FriendNetwork? _network;
  StreamSubscription<List<FriendLink>>? _friendSubscription;
  List<FriendLink> _links = [];
  final Set<String> _busy = {};
  String? _friendError;
  bool _networkReady = false;

  @override
  void initState() {
    super.initState();
    _network =
        widget.network ??
        (AccountService.configured && AccountService.auth.currentUser != null
            ? FirestoreFriendNetwork()
            : null);
    _subscribe();
  }

  void _subscribe() {
    _friendSubscription?.cancel();
    _friendSubscription = _network?.watch().listen(
      (links) {
        if (!mounted) return;
        setState(() {
          _links = links;
          _friendError = null;
          _networkReady = true;
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _networkReady = false;
          _friendError = _friendFailure(error);
        });
      },
    );
  }

  String _friendFailure(Object error) =>
      error is FirebaseException && error.code == 'permission-denied'
      ? 'Fitur pertemanan belum diizinkan Firebase. Publish rules terbaru lalu coba lagi.'
      : error is StateError
      ? error.message.toString()
      : 'Belum berhasil. Periksa koneksi lalu coba lagi.';

  Future<void> _action(String id, Future<void> Function() action) async {
    if (_busy.contains(id)) return;
    setState(() => _busy.add(id));
    try {
      await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_friendFailure(error))));
      }
    } finally {
      if (mounted) setState(() => _busy.remove(id));
    }
  }

  Widget? _playerAction(PlayerSummary player) {
    if (player.isCurrentUser || _network == null) return null;
    FriendLink? relationship;
    for (final link in _links) {
      if (link.otherId(_network.uid) == player.id) {
        relationship = link;
        break;
      }
    }
    if (relationship != null) {
      return Text(
        relationship.accepted
            ? 'Teman'
            : relationship.sender == _network.uid
            ? 'Terkirim'
            : 'Permintaan masuk',
        style: Theme.of(context).textTheme.labelMedium,
      );
    }
    return IconButton(
      tooltip: _busy.contains(player.id) ? 'Mengirim…' : 'Tambah teman',
      icon: Icon(
        _busy.contains(player.id)
            ? Icons.hourglass_top_rounded
            : Icons.person_add_alt_1_rounded,
      ),
      onPressed: !_networkReady || _busy.contains(player.id)
          ? null
          : () => _action(player.id, () => _network.send(player)),
    );
  }

  void _changed(String value) {
    _debounce?.cancel();
    _request++;
    setState(() {
      _error = null;
      _players = [];
      _searched = false;
      _loading = value.trim().length >= 2;
    });
    if (value.trim().length < 2) return;
    _debounce = Timer(const Duration(milliseconds: 400), _find);
  }

  Future<void> _find() async {
    _debounce?.cancel();
    final text = _controller.text.trim();
    if (text.length < 2) return;
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final players = await _search.search(text);
      if (!mounted || request != _request) return;
      setState(() {
        _players = players;
        _searched = true;
      });
    } catch (error) {
      if (!mounted || request != _request) return;
      setState(
        () => _error = error is FirebaseException
            ? switch (error.code) {
                'permission-denied' =>
                  'Firebase belum mengizinkan sinkronisasi atau pencarian pemain. Aturan database perlu diperbarui.',
                'profile-not-found' =>
                  'Profil akun ini belum tersedia. Keluar lalu masuk kembali untuk menyiapkan profil.',
                _ =>
                  'Pencarian belum berhasil. Periksa koneksi lalu coba lagi.',
              }
            : 'Pencarian belum berhasil. Periksa koneksi lalu coba lagi.',
      );
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _friendSubscription?.cancel();
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
          children: [
            const FriendsIntro(),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              onChanged: _changed,
              onSubmitted: (_) => _find(),
              maxLength: 60,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Cari nama pemain',
                counterText: '',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  tooltip: 'Hapus pencarian',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _controller.clear();
                    _changed('');
                  },
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ..._results(),
            if (_network != null) ...[
              const SizedBox(height: 28),
              if (_friendError != null)
                FriendsMessage(
                  title: 'Pertemanan belum tersedia',
                  description: _friendError!,
                  retry: _subscribe,
                )
              else if (!_networkReady)
                const Center(child: CircularProgressIndicator())
              else
                FriendLists(
                  links: _links,
                  uid: _network.uid,
                  busy: _busy,
                  onAccept: (link) => _action(
                    link.otherId(_network.uid),
                    () => _network.accept(link),
                  ),
                  onRemove: (link) => _action(
                    link.otherId(_network.uid),
                    () => _network.remove(link),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _results() {
    if (_loading) {
      return [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      ];
    }
    if (_error != null) {
      return [
        FriendsMessage(
          title: 'Belum bisa mencari',
          description: _error!,
          retry: _find,
        ),
      ];
    }
    if (!_searched) {
      return [
        const FriendsMessage(
          title: 'Siapa teman belajarmu?',
          description:
              'Ketik minimal 2 huruf. Nama pemain akan muncul di sini.',
        ),
      ];
    }
    if (_players.isEmpty) {
      return [
        const FriendsMessage(
          title: 'Belum ketemu',
          description:
              'Coba awalan nama lain. Pemain perlu login lagi agar muncul di pencarian.',
        ),
      ];
    }
    return [
      Text(
        'Pemain ditemukan · ${_players.length}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 12),
      ..._players.map(
        (player) => PlayerCard(player: player, action: _playerAction(player)),
      ),
      if (_players.length == 20)
        const Text('Persempit nama untuk hasil yang lebih spesifik.'),
    ];
  }
}
