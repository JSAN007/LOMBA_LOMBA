import 'package:cloud_firestore/cloud_firestore.dart';
import 'account_service.dart';
import 'friends_service.dart';

class FriendLink {
  const FriendLink({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.senderName,
    required this.recipientName,
    required this.accepted,
  });
  final String id, sender, recipient, senderName, recipientName;
  final bool accepted;
  String otherId(String uid) => sender == uid ? recipient : sender;
  String otherName(String uid) => sender == uid ? recipientName : senderName;
}

abstract class FriendNetwork {
  String get uid;
  Stream<List<FriendLink>> watch();
  Future<void> send(PlayerSummary player);
  Future<void> accept(FriendLink link);
  Future<void> remove(FriendLink link);
}

class FirestoreFriendNetwork implements FriendNetwork {
  FirestoreFriendNetwork() : uid = AccountService.auth.currentUser!.uid;
  @override
  final String uid;
  CollectionReference<Map<String, dynamic>> get _links =>
      FirebaseFirestore.instance.collection('friendships');
  @override
  Stream<List<FriendLink>> watch() => _links
      .where('members', arrayContains: uid)
      .limit(200)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          return FriendLink(
            id: doc.id,
            sender: data['sender'] as String,
            recipient: data['recipient'] as String,
            senderName: data['senderName'] as String,
            recipientName: data['recipientName'] as String,
            accepted: data['status'] == 'accepted',
          );
        }).toList(),
      );
  @override
  Future<void> send(PlayerSummary player) async {
    if (player.id == uid) {
      throw StateError('Tidak bisa menambahkan diri sendiri.');
    }
    final members = [uid, player.id]..sort();
    final reference = _links.doc(members.join('_'));
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final existing = await transaction.get(reference);
      if (existing.exists) {
        throw StateError('Permintaan atau pertemanan sudah ada.');
      }
      final sender = await transaction.get(
        FirebaseFirestore.instance.collection('players').doc(uid),
      );
      final recipient = await transaction.get(
        FirebaseFirestore.instance.collection('players').doc(player.id),
      );
      if (!sender.exists || !recipient.exists) {
        throw StateError('Profil pemain belum tersedia.');
      }
      transaction.set(reference, {
        'members': members,
        'sender': uid,
        'recipient': player.id,
        'senderName': sender.data()!['displayName'],
        'recipientName': recipient.data()!['displayName'],
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> accept(FriendLink link) =>
      _links.doc(link.id).update({'status': 'accepted'});
  @override
  Future<void> remove(FriendLink link) => _links.doc(link.id).delete();
}
