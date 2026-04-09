import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream that listens for whether a user is logged in or out
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get the current user synchronously
  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password, String username) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Save the username directly to the Firebase Auth profile
    await cred.user?.updateDisplayName(username);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // NEW: Real Firebase password change logic
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in.");
    if (user.email == null) throw Exception("User has no email.");

    // Step 1: Re-authenticate to prove the user owns the account right now
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Step 2: Actually update the password
    await user.updatePassword(newPassword);
  }
}