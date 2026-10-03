import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ProgressStore {
  Future<Map<String, dynamic>?> load();
  Future<void> save(Map<String, dynamic> progress);
}

/// One store is permanently bound to one account, including pending writes.
class FirestoreProgressStore implements ProgressStore {
  FirestoreProgressStore(String uid, {FirebaseFirestore? firestore})
    : _document = (firestore ?? FirebaseFirestore.instance)
          .collection('profiles')
          .doc(uid)
          .collection('progress')
          .doc('current');

  final DocumentReference<Map<String, dynamic>> _document;

  @override
  Future<Map<String, dynamic>?> load() async {
    final snapshot = await _document
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 12));
    return snapshot.data();
  }

  @override
  Future<void> save(Map<String, dynamic> progress) => _document
      .set({...progress, 'updatedAt': FieldValue.serverTimestamp()})
      .timeout(const Duration(seconds: 12));
}
