import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Access point for authentication methods
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Keeps track of user authentication state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Watches user Firestore data for updates
final userProfileProvider = StreamProvider.autoDispose((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snap) => snap.data());
});


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 

  // Signup
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Store username in Firebase
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'username': username,
    });

    return userCredential;
  }

  // Login
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Signout
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
}
