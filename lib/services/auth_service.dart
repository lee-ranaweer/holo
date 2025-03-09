import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Access point for authentication methods
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Keeps track of user authentication state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Signup
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
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
