import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

abstract class AppleSignInClient {
  Future<AuthorizationCredentialAppleID> getAppleIDCredential({
    required List<AppleIDAuthorizationScopes> scopes,
    String? nonce,
  });
}

class DefaultAppleSignInClient implements AppleSignInClient {
  const DefaultAppleSignInClient();

  @override
  Future<AuthorizationCredentialAppleID> getAppleIDCredential({
    required List<AppleIDAuthorizationScopes> scopes,
    String? nonce,
  }) {
    return SignInWithApple.getAppleIDCredential(scopes: scopes, nonce: nonce);
  }
}

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    AppleSignInClient? appleSignInClient,
    bool initializeGoogleSignIn = true,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _appleSignInClient =
           appleSignInClient ?? const DefaultAppleSignInClient() {
    if (!kIsWeb && initializeGoogleSignIn) {
      unawaited(_initializeGoogleSignIn());
    } else {
      _googleInitialization.complete();
    }
  }

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final AppleSignInClient _appleSignInClient;
  final Completer<void> _googleInitialization = Completer<void>();

  // Stream that listens for whether a user is logged in or out
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get the current user synchronously
  User? get currentUser => _auth.currentUser;

  Future<void> ensureGoogleSignInInitialized() => _googleInitialization.future;

  Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialization.isCompleted) {
      return;
    }

    try {
      await _googleSignIn.initialize();
      _googleInitialization.complete();
    } catch (error, stackTrace) {
      _googleInitialization.completeError(error, stackTrace);
    }
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      await _auth.signInWithPopup(provider);
      return;
    }

    await ensureGoogleSignInInitialized();
    final GoogleSignInAccount user = await _googleSignIn.authenticate();
    final String? idToken = user.authentication.idToken;
    if (idToken == null) {
      throw Exception('Google Sign-In returned no ID token.');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    await _auth.signInWithCredential(credential);
  }

  Future<void> signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256OfString(rawNonce);
    final appleCredential = await _appleSignInClient.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final provider = OAuthProvider('apple.com');
    final credential = provider.credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    await _auth.signInWithCredential(credential);
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
    if (!kIsWeb) {
      try {
        await ensureGoogleSignInInitialized();
        await _googleSignIn.signOut();
      } catch (error) {
        debugPrint('Google Sign-In sign out skipped: $error');
      }
    }
    await _auth.signOut();
  }

  void dispose() {}

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();

    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256OfString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Firebase password change logic
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in.");
    if (user.email == null) throw Exception("User has no email.");

    // Re-authenticate to prove the user owns the account right now
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    await user.updatePassword(newPassword);
  }
}
