import 'dart:async';

import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../support/mocks.dart';
import '../../support/pump_app.dart';

Finder _textFieldWithLabel(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  );
}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.ensureGoogleSignInInitialized(),
    ).thenAnswer((_) async {});
    when(() => mockAuthRepository.dispose()).thenReturn(null);
  });

  testWidgets('submits trimmed credentials on login', (tester) async {
    when(
      () => mockAuthRepository.signIn(any(), any()),
    ).thenAnswer((_) async {});

    await pumpWidgetApp(
      tester,
      child: const LoginScreen(),
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );

    await tester.enterText(
      _textFieldWithLabel('Email Address'),
      '  fan@example.com  ',
    );
    await tester.enterText(_textFieldWithLabel('Password'), '  secret123  ');

    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pump();

    verify(
      () => mockAuthRepository.signIn('fan@example.com', 'secret123'),
    ).called(1);
  });

  testWidgets('shows a loading spinner while login is in flight', (
    tester,
  ) async {
    final completer = Completer<void>();
    when(
      () => mockAuthRepository.signIn(any(), any()),
    ).thenAnswer((_) => completer.future);

    await pumpWidgetApp(
      tester,
      child: const LoginScreen(),
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );

    await tester.enterText(
      _textFieldWithLabel('Email Address'),
      'fan@example.com',
    );
    await tester.enterText(_textFieldWithLabel('Password'), 'secret123');
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );

    completer.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('renders a cleaned error message when login fails', (
    tester,
  ) async {
    when(
      () => mockAuthRepository.signIn(any(), any()),
    ).thenThrow(Exception('[firebase_auth/wrong-password] Wrong password'));

    await pumpWidgetApp(
      tester,
      child: const LoginScreen(),
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );

    await tester.enterText(
      _textFieldWithLabel('Email Address'),
      'fan@example.com',
    );
    await tester.enterText(_textFieldWithLabel('Password'), 'bad-password');
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Wrong password'), findsOneWidget);
  });

  testWidgets('calls Google sign in from the social button', (tester) async {
    when(() => mockAuthRepository.signInWithGoogle()).thenAnswer((_) async {});

    await pumpWidgetApp(
      tester,
      child: const LoginScreen(),
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );

    await tester.tap(find.text('Continue with Google'));
    await tester.pump();

    verify(() => mockAuthRepository.signInWithGoogle()).called(1);
  });

  testWidgets('renders a Google sign in error message', (tester) async {
    when(
      () => mockAuthRepository.signInWithGoogle(),
    ).thenThrow(Exception('popup blocked'));

    await pumpWidgetApp(
      tester,
      child: const LoginScreen(),
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(
      find.text('Google sign in failed: Exception: popup blocked'),
      findsOneWidget,
    );
  });

  testWidgets('shows Apple sign in on iOS and wires the button', (
    tester,
  ) async {
    when(() => mockAuthRepository.signInWithApple()).thenAnswer((_) async {});

    await pumpWidgetApp(
      tester,
      child: const LoginScreen(platformOverride: TargetPlatform.iOS),
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );

    expect(find.byType(SignInWithAppleButton), findsOneWidget);

    await tester.tap(find.byType(SignInWithAppleButton));
    await tester.pump();

    verify(() => mockAuthRepository.signInWithApple()).called(1);
  });
}
