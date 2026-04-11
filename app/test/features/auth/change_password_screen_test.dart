import 'dart:async';

import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/auth/presentation/screens/change_password_screen.dart';
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

  testWidgets('validates password length before calling the repository', (
    tester,
  ) async {
    await pumpWidgetApp(
      tester,
      child: const ChangePasswordScreen(),
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );

    await tester.enterText(_textFieldWithLabel('Current Password'), 'oldpass');
    await tester.enterText(_textFieldWithLabel('New Password'), '123');
    await tester.tap(find.text('Update Password'));
    await tester.pump();

    expect(
      find.text('New password must be at least 6 characters.'),
      findsOneWidget,
    );
    verifyNever(() => mockAuthRepository.changePassword(any(), any()));
  });

  testWidgets(
    'shows loading state and success feedback after password update',
    (tester) async {
      final completer = Completer<void>();
      when(
        () => mockAuthRepository.changePassword(any(), any()),
      ).thenAnswer((_) => completer.future);

      await pumpWidgetApp(
        tester,
        child: const ChangePasswordScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );

      await tester.enterText(
        _textFieldWithLabel('Current Password'),
        ' oldpass ',
      );
      await tester.enterText(
        _textFieldWithLabel('New Password'),
        ' newpass123 ',
      );
      await tester.tap(find.text('Update Password'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      verify(
        () => mockAuthRepository.changePassword('oldpass', 'newpass123'),
      ).called(1);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        find.text('New password must be at least 6 characters.'),
        findsNothing,
      );
    },
  );

  testWidgets('renders cleaned repository errors', (tester) async {
    when(() => mockAuthRepository.changePassword(any(), any())).thenThrow(
      Exception(
        '[firebase_auth/requires-recent-login] Re-authentication needed',
      ),
    );

    await pumpWidgetApp(
      tester,
      child: const ChangePasswordScreen(),
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );

    await tester.enterText(_textFieldWithLabel('Current Password'), 'oldpass');
    await tester.enterText(_textFieldWithLabel('New Password'), 'newpass123');
    await tester.tap(find.text('Update Password'));
    await tester.pumpAndSettle();

    expect(find.text('Re-authentication needed'), findsOneWidget);
  });
}
