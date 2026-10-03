import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> deleteAccountInOrder({
  required Future<void> Function() reauthenticate,
  required Future<void> Function() pauseWrites,
  required Future<void> Function() eraseData,
  required Future<void> Function() eraseIdentity,
}) async {
  await reauthenticate();
  await pauseWrites();
  await eraseData();
  await eraseIdentity();
}

class AccountDeletionService {
  AccountDeletionService({required this.user, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  final User user;
  final FirebaseFirestore _firestore;

  Future<void> delete({
    required String password,
    required Future<void> Function() pauseWrites,
  }) => deleteAccountInOrder(
    reauthenticate: () async {
      final email = user.email;
      if (email == null || password.isEmpty) {
        throw StateError('Email/password required');
      }
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );
      await user.getIdToken(true);
    },
    pauseWrites: () async {
      await pauseWrites();
      // A timed-out Firestore write may still be queued in the native SDK.
      // Drain that queue too before deleting, not only the Dart save futures.
      await _firestore.waitForPendingWrites().timeout(
        const Duration(seconds: 15),
      );
    },
    eraseData: _eraseData,
    eraseIdentity: user.delete,
  );

  Future<void> _eraseData() async {
    // Query every known owned store before deleting anything. Each retry is
    // idempotent; Auth remains available if a data batch fails.
    final profile = _firestore.collection('profiles').doc(user.uid);
    final references = <DocumentReference<Map<String, dynamic>>>[];
    for (final collection in [
      profile.collection('activities'),
      _firestore.collection('friendships'),
    ]) {
      DocumentSnapshot<Map<String, dynamic>>? cursor;
      while (true) {
        Query<Map<String, dynamic>> query = collection;
        if (collection.id == 'friendships') {
          query = query.where('members', arrayContains: user.uid);
        }
        query = query.orderBy(FieldPath.documentId).limit(200);
        if (cursor != null) query = query.startAfterDocument(cursor);
        final page = await query
            .get(const GetOptions(source: Source.server))
            .timeout(const Duration(seconds: 15));
        references.addAll(page.docs.map((doc) => doc.reference));
        if (page.docs.length < 200) break;
        cursor = page.docs.last;
      }
    }
    references.addAll([
      profile.collection('progress').doc('current'),
      _firestore.collection('players').doc(user.uid),
      profile,
    ]);
    for (var start = 0; start < references.length; start += 400) {
      final batch = _firestore.batch();
      for (final ref in references.skip(start).take(400)) {
        batch.delete(ref);
      }
      await batch.commit().timeout(const Duration(seconds: 15));
    }
  }
}
