abstract class AuthRepository {
  Stream<String?> get authStateChanges;
  Future<void> signInWithGoogle();
  Future<void> signOut();
  String? get currentUser;
}
