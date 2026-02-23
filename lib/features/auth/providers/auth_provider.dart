import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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

/// When set, app shows dashboard without real sign-in (for demo/preview).
final demoUserProvider = StateProvider<AppUser?>((ref) => null);

/// Current user: demo user if set, otherwise signed-in user.
final currentUserProvider = Provider<AppUser?>((ref) {
  final demo = ref.watch(demoUserProvider);
  if (demo != null) return demo;
  return ref.watch(authStateProvider).valueOrNull;
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
    UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('This email is already registered. Sign in instead.');
        case 'invalid-email':
          throw Exception('Invalid email address.');
        case 'weak-password':
          throw Exception('Password is too weak. Use at least 6 characters.');
        case 'operation-not-allowed':
          throw Exception('Email sign-up is disabled. Enable it in Firebase Console → Authentication → Sign-in method.');
        case 'network-request-failed':
          throw Exception('Network error. Check your connection.');
        default:
          throw Exception(e.message ?? 'Sign up failed. Please try again.');
      }
    }
    final uid = cred.user!.uid;
    final user = AppUser(
      uid: uid,
      email: email.trim(),
      role: role,
      displayName: displayName?.trim(),
    );
    try {
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
    } on FirebaseException catch (e) {
      await _auth.currentUser?.delete();
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied. In Firebase Console: deploy Firestore rules (firebase deploy --only firestore:rules) or set rules to allow writes.');
      }
      rethrow;
    } catch (e) {
      await _auth.currentUser?.delete();
      rethrow;
    }
    return user;
  }

  Future<AppUser> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found for this email. Please sign up first.');
        case 'wrong-password':
          throw Exception('Wrong password. Please try again.');
        case 'invalid-credential':
          throw Exception('Invalid email or password.');
        case 'invalid-email':
          throw Exception('Invalid email address.');
        case 'user-disabled':
          throw Exception('This account has been disabled.');
        case 'network-request-failed':
          throw Exception('Network error. Check your connection.');
        default:
          throw Exception(e.message ?? 'Sign in failed. Please try again.');
      }
    }
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
