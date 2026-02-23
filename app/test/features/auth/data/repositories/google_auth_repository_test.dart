import 'dart:async';
import 'package:app/features/auth/data/repositories/google_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FakeGoogleSignIn extends Fake implements GoogleSignIn {
  final StreamController<GoogleSignInAccount?> _controller =
      StreamController<GoogleSignInAccount?>.broadcast();

  GoogleSignInAccount? _currentUser;
  final bool _signInShouldFail;

  FakeGoogleSignIn({bool signInShouldFail = false})
      : _signInShouldFail = signInShouldFail;

  @override
  Stream<GoogleSignInAccount?> get onCurrentUserChanged => _controller.stream;
  
  @override
  GoogleSignInAccount? get currentUser => _currentUser;

  @override
  Future<GoogleSignInAccount?> signIn() async {
    if (_signInShouldFail) {
      return null;
    }
    _currentUser = FakeGoogleSignInAccount();
    _controller.add(_currentUser);
    return _currentUser;
  }
  
  @override
  Future<GoogleSignInAccount?> signOut() async {
    final oldUser = _currentUser;
    _currentUser = null;
    _controller.add(null);
    return oldUser;
  }
  
  @override
  Future<GoogleSignInAccount?> disconnect() async {
    return signOut();
  }
}

class FakeGoogleSignInAccount extends Fake implements GoogleSignInAccount {
  @override
  Future<GoogleSignInAuthentication> get authentication async =>
      FakeGoogleSignInAuthentication();
  
  @override
  String get id => 'fake-user-id';
}

class FakeGoogleSignInAuthentication extends Fake
    implements GoogleSignInAuthentication {
  @override
  String? get accessToken => 'fake-access-token';

  @override
  String? get idToken => 'fake-id-token';
}


void main() {
  late GoogleAuthRepository repository;

  group('GoogleAuthRepository - Success', () {
    setUp(() {
      final fakeGoogleSignIn = FakeGoogleSignIn();
      repository = GoogleAuthRepository(googleSignIn: fakeGoogleSignIn);
    });

    test('signInWithGoogle should complete and update user state', () async {
      await repository.signInWithGoogle();
      expect(repository.currentUser, isNotNull);
    });

    test('signOut should clear the user', () async {
      await repository.signInWithGoogle();
      expect(repository.currentUser, isNotNull);

      await repository.signOut();
      expect(repository.currentUser, isNull);
    });
  });

  group('GoogleAuthRepository - Failure', () {
    setUp(() {
      final fakeGoogleSignIn = FakeGoogleSignIn(signInShouldFail: true);
      repository = GoogleAuthRepository(googleSignIn: fakeGoogleSignIn);
    });

    test('signInWithGoogle should throw exception when sign in returns null', () {
      expect(() => repository.signInWithGoogle(), throwsException);
    });
  });
}
