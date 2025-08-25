import 'package:firebase_auth/firebase_auth.dart';

// This class is a singleton to ensure we only have one instance.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // --- STREAMS ---
  // Stream to listen for auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // --- METHODS ---

  // Sign In with Email & Password
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign Up with Email & Password
  Future<UserCredential> signUpWithEmail(String email, String password) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign In with Google
  Future<UserCredential> signInWithGoogle() {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();
    return _firebaseAuth.signInWithPopup(googleProvider);
  }
  
  // Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // Sign Out
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}