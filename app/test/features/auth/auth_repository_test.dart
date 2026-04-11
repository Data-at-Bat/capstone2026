import 'package:app/features/auth/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockAppleSignInClient extends Mock implements AppleSignInClient {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockAppleSignInClient mockAppleSignInClient;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockAppleSignInClient = MockAppleSignInClient();
  });

  AuthRepository buildRepository({bool initializeGoogleSignIn = false}) {
    return AuthRepository(
      auth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
      appleSignInClient: mockAppleSignInClient,
      initializeGoogleSignIn: initializeGoogleSignIn,
    );
  }

  test('returns auth state changes and current user from FirebaseAuth', () {
    final mockUser = MockUser();
    final authStateStream = Stream<User?>.value(mockUser);
    when(
      () => mockFirebaseAuth.authStateChanges(),
    ).thenAnswer((_) => authStateStream);
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

    final repository = buildRepository();

    expect(repository.authStateChanges, same(authStateStream));
    expect(repository.currentUser, same(mockUser));
  });

  test('signIn forwards email/password to FirebaseAuth', () async {
    when(
      () => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => MockUserCredential());

    final repository = buildRepository();

    await repository.signIn('fan@example.com', 'secret123');

    verify(
      () => mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'fan@example.com',
        password: 'secret123',
      ),
    ).called(1);
  });

  test('signUp creates the user and updates their display name', () async {
    final mockUser = MockUser();
    final mockUserCredential = MockUserCredential();
    when(
      () => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => mockUserCredential);
    when(() => mockUserCredential.user).thenReturn(mockUser);
    when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});

    final repository = buildRepository();

    await repository.signUp('fan@example.com', 'secret123', 'slugger');

    verify(
      () => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'fan@example.com',
        password: 'secret123',
      ),
    ).called(1);
    verify(() => mockUser.updateDisplayName('slugger')).called(1);
  });

  test(
    'signInWithGoogle exchanges the Google id token with Firebase',
    () async {
      final mockGoogleAccount = MockGoogleSignInAccount();
      when(
        () => mockGoogleSignIn.authenticate(),
      ).thenAnswer((_) async => mockGoogleAccount);
      when(() => mockGoogleAccount.authentication).thenReturn(
        const GoogleSignInAuthentication(idToken: 'google-id-token'),
      );
      when(
        () => mockFirebaseAuth.signInWithCredential(any()),
      ).thenAnswer((_) async => MockUserCredential());

      final repository = buildRepository();

      await repository.signInWithGoogle();

      final credential =
          verify(
                () => mockFirebaseAuth.signInWithCredential(captureAny()),
              ).captured.single
              as AuthCredential;
      expect(credential.providerId, GoogleAuthProvider.PROVIDER_ID);
      expect(credential.signInMethod, GoogleAuthProvider.GOOGLE_SIGN_IN_METHOD);
    },
  );

  test('signInWithGoogle throws when Google returns no id token', () async {
    final mockGoogleAccount = MockGoogleSignInAccount();
    when(
      () => mockGoogleSignIn.authenticate(),
    ).thenAnswer((_) async => mockGoogleAccount);
    when(
      () => mockGoogleAccount.authentication,
    ).thenReturn(const GoogleSignInAuthentication(idToken: null));

    final repository = buildRepository();

    await expectLater(
      repository.signInWithGoogle(),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('no ID token'),
        ),
      ),
    );
    verifyNever(() => mockFirebaseAuth.signInWithCredential(any()));
  });

  test('signInWithApple sends idToken and rawNonce to Firebase', () async {
    when(
      () => mockAppleSignInClient.getAppleIDCredential(
        scopes: any(named: 'scopes'),
        nonce: any(named: 'nonce'),
      ),
    ).thenAnswer(
      (_) async => const AuthorizationCredentialAppleID(
        userIdentifier: 'apple-user',
        givenName: 'Data',
        familyName: 'Fan',
        authorizationCode: 'auth-code',
        email: 'fan@example.com',
        identityToken: 'apple-id-token',
        state: null,
      ),
    );
    when(
      () => mockFirebaseAuth.signInWithCredential(any()),
    ).thenAnswer((_) async => MockUserCredential());

    final repository = buildRepository();

    await repository.signInWithApple();

    final appleCall = verify(
      () => mockAppleSignInClient.getAppleIDCredential(
        scopes: captureAny(named: 'scopes'),
        nonce: captureAny(named: 'nonce'),
      ),
    ).captured;
    final scopes = appleCall[0] as List<AppleIDAuthorizationScopes>;
    final hashedNonce = appleCall[1] as String;
    expect(
      scopes,
      containsAll([
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]),
    );
    expect(hashedNonce, isNotEmpty);

    final credential =
        verify(
              () => mockFirebaseAuth.signInWithCredential(captureAny()),
            ).captured.single
            as OAuthCredential;
    expect(credential.providerId, 'apple.com');
    expect(credential.idToken, 'apple-id-token');
    expect(credential.rawNonce, isNotNull);
    expect(credential.rawNonce, isNot(equals(hashedNonce)));
  });

  test('signOut signs out Google before Firebase when available', () async {
    when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async {});
    when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

    final repository = buildRepository();

    await repository.signOut();

    verifyInOrder([
      () => mockGoogleSignIn.signOut(),
      () => mockFirebaseAuth.signOut(),
    ]);
  });

  test(
    'signOut still logs out of Firebase when Google sign out fails',
    () async {
      when(() => mockGoogleSignIn.signOut()).thenThrow(Exception('bad config'));
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      final repository = buildRepository();

      await repository.signOut();

      verify(() => mockGoogleSignIn.signOut()).called(1);
      verify(() => mockFirebaseAuth.signOut()).called(1);
    },
  );

  test('changePassword reauthenticates before updating the password', () async {
    final mockUser = MockUser();
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.email).thenReturn('fan@example.com');
    when(
      () => mockUser.reauthenticateWithCredential(any()),
    ).thenAnswer((_) async => MockUserCredential());
    when(() => mockUser.updatePassword(any())).thenAnswer((_) async {});

    final repository = buildRepository();

    await repository.changePassword('oldpass', 'newpass123');

    final reauthCredential =
        verify(
              () => mockUser.reauthenticateWithCredential(captureAny()),
            ).captured.single
            as AuthCredential;
    expect(reauthCredential.providerId, EmailAuthProvider.PROVIDER_ID);
    verify(() => mockUser.updatePassword('newpass123')).called(1);
  });
}
