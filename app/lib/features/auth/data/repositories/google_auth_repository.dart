import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';

class GoogleAuthRepository implements AuthRepository {
  final GoogleSignIn _googleSignIn;
  final StreamController<String?> _authStateController = StreamController<String?>.broadcast();

  GoogleAuthRepository({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _authStateController.add(account?.id);
    });
  }

  @override
  Stream<String?> get authStateChanges async* {
    yield _googleSignIn.currentUser?.id;
    yield* _authStateController.stream;
  }

  @override
  String? get currentUser => _googleSignIn.currentUser?.id;

  @override
  Future<void> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw Exception('Sign in cancelled by user');
      }
      
      final authentication = await account.authentication;
      final accessToken = authentication.accessToken;
      final idToken = authentication.idToken;
      
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
    } catch (e) {
      rethrow;
    }
  }
}
