import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountService {
  static bool get configured => Firebase.apps.isNotEmpty;
  static Future<void> initialize() async {
    if (configured) return;
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_APP_ID');
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
    const senderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    if ([apiKey, appId, projectId, senderId].any((value) => value.isEmpty)) {
      return;
    }
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        projectId: projectId,
        messagingSenderId: senderId,
        authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
        iosBundleId: String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
      ),
    );
  }

  static FirebaseAuth get auth => FirebaseAuth.instance;

  static Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    final result = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await result.user!.updateDisplayName(name);
    await result.user!.sendEmailVerification();
  }

  static Future<void> ensureProfile(User user) async {
    await user.getIdToken(true);
    final reference = FirebaseFirestore.instance
        .collection('profiles')
        .doc(user.uid);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists) {
        transaction.set(reference, {
          'displayName': user.displayName ?? 'Pelajar',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
    // Directory availability must not prevent existing accounts from logging in.
    try {
      await publishPlayerDirectory(user);
    } on FirebaseException {
      // Old deployed rules may not yet allow the new public directory.
      // The next login retries publication after the rules are updated.
    }
  }

  static Future<void> publishPlayerDirectory(User user) async {
    final profile = await FirebaseFirestore.instance
        .collection('profiles')
        .doc(user.uid)
        .get(const GetOptions(source: Source.server));
    final name = profile.data()?['displayName'] as String?;
    if (name == null || name.trim().length < 2) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'profile-not-found',
        message: 'Profil akun belum tersedia.',
      );
    }
    await FirebaseFirestore.instance.collection('players').doc(user.uid).set({
      'displayName': name,
      'searchName': name.toLowerCase(),
    });
  }

  static String errorMessage(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'invalid-credential' ||
        'user-not-found' ||
        'wrong-password' => 'Email atau password tidak sesuai.',
        'email-already-in-use' => 'Email ini sudah terdaftar. Silakan masuk.',
        'invalid-email' => 'Alamat email tidak valid.',
        'weak-password' =>
          'Password terlalu lemah. Gunakan minimal 8 karakter.',
        'too-many-requests' => 'Terlalu banyak percobaan. Coba lagi nanti.',
        'network-request-failed' => 'Koneksi terputus. Periksa internet kamu.',
        _ => 'Permintaan belum berhasil. Silakan coba lagi.',
      };
    }
    return 'Permintaan belum berhasil. Periksa koneksi dan coba lagi.';
  }
}
