import 'dart:async';

import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/auth/presentation/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
  });

  testWidgets('submits trimmed signup details', (tester) async {
    when(
      () => mockAuthRepository.signUp(any(), any(), any()),
    ).thenAnswer((_) async {});

    await pumpWidgetApp(
      tester,
      child: const SignupScreen(),
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );

    await tester.enterText(_textFieldWithLabel('Username'), '  datafan  ');
    await tester.enterText(
      _textFieldWithLabel('Email Address'),
      '  fan@example.com  ',
    );
    await tester.enterText(_textFieldWithLabel('Password'), '  secret123  ');

    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    verify(
      () =>
          mockAuthRepository.signUp('fan@example.com', 'secret123', 'datafan'),
    ).called(1);
  });

  testWidgets('shows loading state while signup is running', (tester) async {
    final completer = Completer<void>();
    when(
      () => mockAuthRepository.signUp(any(), any(), any()),
    ).thenAnswer((_) => completer.future);

    await pumpWidgetApp(
      tester,
      child: const SignupScreen(),
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );

    await tester.enterText(_textFieldWithLabel('Username'), 'datafan');
    await tester.enterText(
      _textFieldWithLabel('Email Address'),
      'fan@example.com',
    );
    await tester.enterText(_textFieldWithLabel('Password'), 'secret123');
    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );

    completer.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('renders cleaned signup errors', (tester) async {
    when(() => mockAuthRepository.signUp(any(), any(), any())).thenThrow(
      Exception('[firebase_auth/email-already-in-use] Email already in use'),
    );

    await pumpWidgetApp(
      tester,
      child: const SignupScreen(),
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );

    await tester.enterText(_textFieldWithLabel('Username'), 'datafan');
    await tester.enterText(
      _textFieldWithLabel('Email Address'),
      'fan@example.com',
    );
    await tester.enterText(_textFieldWithLabel('Password'), 'secret123');
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Email already in use'), findsOneWidget);
  });
}
