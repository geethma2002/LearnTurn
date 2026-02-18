import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../domain/user_model.dart';

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((fbUser) async {
    if (fbUser == null) return null;
    final doc = await FirebaseFirestore.instance
        .collection(AppCollections.users)
        .doc(fbUser.uid)
        .get();
    if (!doc.exists) return null;
    return AppUser.fromMap({...doc.data()!, 'uid': doc.id});
  });
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<AppUser> signUp({
    required String email,
    required String password,
    required UserRole role,
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = cred.user!.uid;
    final user = AppUser(
      uid: uid,
      email: email.trim(),
      role: role,
      displayName: displayName?.trim(),
    );
    await _db.collection(AppCollections.users).doc(uid).set(user.toMap());
    if (role == UserRole.tutor) {
      await _db.collection(AppCollections.tutors).doc(uid).set({
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await _db.collection(AppCollections.students).doc(uid).set({
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return user;
  }

  Future<AppUser> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = _auth.currentUser!.uid;
    final doc = await _db.collection(AppCollections.users).doc(uid).get();
    if (!doc.exists) {
      await _auth.signOut();
      throw Exception(
        'Account data not found. If you just signed up, try again in a moment, or sign up again.',
      );
    }
    return AppUser.fromMap({...doc.data()!, 'uid': doc.id});
  }

  Future<void> signOut() async => await _auth.signOut();

  User? get currentFirebaseUser => _auth.currentUser;
}
