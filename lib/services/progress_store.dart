import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/learning_activity.dart';

abstract class ActivityStore {
  Future<List<LearningActivity>> loadActivities();
  Future<void> saveActivity(LearningActivity activity);
}

abstract class ProgressStore {
  Future<Map<String, dynamic>?> load();
  Future<void> save(Map<String, dynamic> progress);
}

/// One store is permanently bound to one account, including pending writes.
class FirestoreProgressStore implements ProgressStore, ActivityStore {
  FirestoreProgressStore(String uid, {FirebaseFirestore? firestore})
    : _document = (firestore ?? FirebaseFirestore.instance)
          .collection('profiles')
          .doc(uid)
          .collection('progress')
          .doc('current');

  final DocumentReference<Map<String, dynamic>> _document;

  CollectionReference<Map<String, dynamic>> get _activities =>
      _document.parent.parent!.collection('activities');

  @override
  Future<List<LearningActivity>> loadActivities() async {
    final items = <LearningActivity>[];
    DocumentSnapshot<Map<String, dynamic>>? cursor;
    while (true) {
      Query<Map<String, dynamic>> query = _activities
          .orderBy('occurredAt')
          .limit(200);
      if (cursor != null) query = query.startAfterDocument(cursor);
      final page = await query
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 12));
      items.addAll(
        page.docs.map((doc) => LearningActivity.fromMap(doc.id, doc.data())),
      );
      if (page.docs.length < 200) return items;
      cursor = page.docs.last;
    }
  }

  @override
  Future<void> saveActivity(LearningActivity activity) => _activities
      .doc(activity.id)
      .set(activity.toMap())
      .timeout(const Duration(seconds: 12));

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
