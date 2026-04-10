import 'dart:async';

import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart';
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
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Wrong password'), findsOneWidget);
  });
}
