import 'package:firebase_auth/firebase_auth.dart';

/// Service for handling authentication operations
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get the ID token for the current user
  Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
