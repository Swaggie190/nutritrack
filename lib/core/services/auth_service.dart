import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  Future<String?> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      }
      throw Exception(e.message);
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      // Attempt to sign up the user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("User signed up successfully: ${userCredential.user?.uid}");
      return userCredential.user?.uid;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Log detailed error information
      print("FirebaseAuthException encountered: ${e.code}, ${e.message}");
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else {
        throw Exception(e.message ?? 'An unknown error occurred in signUp.');
      }
    } catch (e) {
      // Log unexpected errors
      print("Unexpected error in signUp: $e");
      throw Exception("Unexpected error in signUp: $e");
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Error sending password reset email');
    }
  }

  Stream<String?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }
}
