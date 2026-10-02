import 'package:cloud_firestore/cloud_firestore.dart';
import 'account_service.dart';

class PlayerSummary {
  const PlayerSummary({
    required this.id,
    required this.name,
    this.isCurrentUser = false,
  });
  final String id;
  final String name;
  final bool isCurrentUser;
}

abstract class PlayerSearch {
  Future<List<PlayerSummary>> search(String text);
}

class FriendsService implements PlayerSearch {
  String? _preparedUid;
  @override
  Future<List<PlayerSummary>> search(String text) async {
    if (!AccountService.configured || AccountService.auth.currentUser == null) {
      throw StateError('account-unavailable');
    }
    final name = text.trim().toLowerCase();
    if (name.length < 2) return [];
    final user = AccountService.auth.currentUser!;
    if (_preparedUid != user.uid) {
      await AccountService.publishPlayerDirectory(
        user,
      ).timeout(const Duration(seconds: 12));
      _preparedUid = user.uid;
    }
    final result = await FirebaseFirestore.instance
        .collection('players')
        .orderBy('searchName')
        .startAt([name])
        .endAt(['$name\uf8ff'])
        .limit(20)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 12));
    return result.docs
        .map(
          (doc) => PlayerSummary(
            id: doc.id,
            name: doc.data()['displayName'] as String,
            isCurrentUser: doc.id == user.uid,
          ),
        )
        .toList();
  }
}
