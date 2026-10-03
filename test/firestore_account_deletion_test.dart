// Deliberate SDK test doubles; production code does not subclass sealed types.
// ignore_for_file: subtype_of_sealed_class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cybernusa/services/account_deletion_service.dart';

class TestUser extends Fake implements User {
  bool deleted = false;
  bool invalidPassword = false;
  @override
  String get uid => 'account-a';
  @override
  String get email => 'a@example.com';
  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential credential,
  ) async {
    if (invalidPassword) throw FirebaseAuthException(code: 'wrong-password');
    return TestCredential();
  }

  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async => 'test-token';
  @override
  Future<void> delete() async {
    deleted = true;
  }
}

class TestCredential extends Fake implements UserCredential {}

class TestFirestore extends Fake implements FirebaseFirestore {
  final documents = <String, Map<String, dynamic>>{};
  bool drained = false;
  bool failCleanup = false;
  final batchSizes = <int>[];
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      TestCollection(this, path);
  @override
  Future<void> waitForPendingWrites() async {
    drained = true;
  }

  @override
  WriteBatch batch() => TestBatch(this);
}

class TestDocument extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  TestDocument(this.db, this.path);
  final TestFirestore db;
  @override
  final String path;
  @override
  String get id => path.split('/').last;
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      TestCollection(db, '${this.path}/$path');
}

class TestCollection extends TestQuery
    implements CollectionReference<Map<String, dynamic>> {
  TestCollection(super.db, super.path);
  @override
  String get id => path.split('/').last;
  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) =>
      TestDocument(db, '$path/$id');
}

class TestQuery extends Fake implements Query<Map<String, dynamic>> {
  TestQuery(this.db, this.path, {this.member, this.after, this.pageSize = 200});
  final TestFirestore db;
  final String path;
  final String? member, after;
  final int pageSize;
  @override
  Query<Map<String, dynamic>> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    return TestQuery(
      db,
      path,
      member: arrayContains as String?,
      after: after,
      pageSize: pageSize,
    );
  }

  @override
  Query<Map<String, dynamic>> orderBy(
    Object field, {
    bool descending = false,
  }) => this;
  @override
  Query<Map<String, dynamic>> limit(int limit) {
    return TestQuery(db, path, member: member, after: after, pageSize: limit);
  }

  @override
  Query<Map<String, dynamic>> startAfterDocument(DocumentSnapshot snapshot) {
    return TestQuery(
      db,
      path,
      member: member,
      after: snapshot.id,
      pageSize: pageSize,
    );
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    final results = db.documents.entries.where((entry) {
      final parent = entry.key.substring(0, entry.key.lastIndexOf('/'));
      final id = entry.key.split('/').last;
      return parent == path &&
          (after == null || id.compareTo(after!) > 0) &&
          (member == null || (entry.value['members'] as List).contains(member));
    }).toList()..sort((a, b) => a.key.compareTo(b.key));
    return TestQuerySnapshot(
      results
          .take(pageSize)
          .map((entry) => TestSnapshot(TestDocument(db, entry.key)))
          .toList(),
    );
  }
}

class TestSnapshot extends Fake
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  TestSnapshot(this.reference);
  @override
  final DocumentReference<Map<String, dynamic>> reference;
  @override
  String get id => reference.id;
}

class TestQuerySnapshot extends Fake
    implements QuerySnapshot<Map<String, dynamic>> {
  TestQuerySnapshot(this.docs);
  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
}

class TestBatch extends Fake implements WriteBatch {
  TestBatch(this.db);
  final TestFirestore db;
  final paths = <String>[];
  @override
  void delete(DocumentReference reference) {
    paths.add(reference.path);
  }

  @override
  Future<void> commit() async {
    expect(db.drained, true);
    if (db.failCleanup) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );
    }
    db.batchSizes.add(paths.length);
    for (final path in paths) {
      db.documents.remove(path);
    }
  }
}

void main() {
  test(
    'Erases paginated owned history, progress, friends, profile, directory; preserves other account',
    () async {
      final db = TestFirestore();
      final user = TestUser();
      for (var i = 0; i < 451; i++) {
        db.documents['profiles/account-a/activities/${i.toString().padLeft(4, '0')}'] =
            {};
      }
      for (final path in [
        'profiles/account-a',
        'players/account-a',
        'profiles/account-a/progress/current',
        'profiles/account-b',
        'players/account-b',
        'profiles/account-b/progress/current',
        'profiles/account-b/activities/one',
      ]) {
        db.documents[path] = {};
      }
      db.documents['friendships/a_b'] = {
        'members': ['account-a', 'account-b'],
      };
      db.documents['friendships/b_c'] = {
        'members': ['account-b', 'account-c'],
      };
      await AccountDeletionService(
        user: user,
        firestore: db,
      ).delete(password: 'password', pauseWrites: () async {});
      expect(user.deleted, true);
      expect(db.documents.keys.toSet(), {
        'profiles/account-b',
        'players/account-b',
        'profiles/account-b/progress/current',
        'profiles/account-b/activities/one',
        'friendships/b_c',
      });
      expect(db.batchSizes, [400, 55]);
    },
  );
  test('Wrong password preserves all data and identity', () async {
    final db = TestFirestore()..documents['profiles/account-a'] = {};
    final user = TestUser()..invalidPassword = true;
    await expectLater(
      AccountDeletionService(
        user: user,
        firestore: db,
      ).delete(password: 'wrong', pauseWrites: () async {}),
      throwsA(isA<FirebaseAuthException>()),
    );
    expect(db.documents.length, 1);
    expect(db.drained, false);
    expect(user.deleted, false);
  });
  test(
    'Denied cleanup does not delete identity and retry can complete',
    () async {
      final db = TestFirestore()
        ..documents['profiles/account-a'] = {}
        ..failCleanup = true;
      final user = TestUser();
      final service = AccountDeletionService(user: user, firestore: db);
      await expectLater(
        service.delete(password: 'password', pauseWrites: () async {}),
        throwsA(isA<FirebaseException>()),
      );
      expect(db.documents.length, 1);
      expect(user.deleted, false);
      db.failCleanup = false;
      await service.delete(password: 'password', pauseWrites: () async {});
      expect(db.documents, isEmpty);
      expect(user.deleted, true);
    },
  );
}
