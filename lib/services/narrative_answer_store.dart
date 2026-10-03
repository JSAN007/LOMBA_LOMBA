import 'package:cloud_firestore/cloud_firestore.dart';
import 'account_service.dart';

abstract class NarrativeAnswerStore {
  Future<String?> load(String questionId);
  Future<void> save(String questionId, String answer);

  static NarrativeAnswerStore forCurrentAccount() {
    final uid = AccountService.configured
        ? AccountService.auth.currentUser?.uid
        : null;
    return uid == null
        ? _UnavailableAnswerStore()
        : FirestoreNarrativeAnswerStore(uid);
  }
}

class FirestoreNarrativeAnswerStore implements NarrativeAnswerStore {
  FirestoreNarrativeAnswerStore(String uid, {FirebaseFirestore? firestore})
    : _answers = (firestore ?? FirebaseFirestore.instance)
          .collection('profiles')
          .doc(uid)
          .collection('narrativeAnswers');

  final CollectionReference<Map<String, dynamic>> _answers;

  @override
  Future<String?> load(String questionId) async {
    final snapshot = await _answers
        .doc(questionId)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 12));
    return snapshot.data()?['answer'] as String?;
  }

  @override
  Future<void> save(String questionId, String answer) => _answers
      .doc(questionId)
      .set({
        'answer': answer,
        'status': 'draft',
        'updatedAt': FieldValue.serverTimestamp(),
      })
      .timeout(const Duration(seconds: 12));
}

class _UnavailableAnswerStore implements NarrativeAnswerStore {
  @override
  Future<String?> load(String questionId) async => null;

  @override
  Future<void> save(String questionId, String answer) async {
    throw StateError('Login diperlukan untuk menyimpan jawaban.');
  }
}
