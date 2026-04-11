import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/auth/presentation/screens/change_password_screen.dart';
import 'package:app/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/mocks.dart';
import '../../support/pump_app.dart';

void main() {
  late MockUser mockUser;

  setUp(() {
    mockUser = MockUser();
    when(() => mockUser.displayName).thenReturn('Data Fan');
    when(() => mockUser.email).thenReturn('fan@example.com');
  });

  testWidgets('renders profile details from the auth state', (tester) async {
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/change-password',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
      ],
    );

    await pumpRouterApp(
      tester,
      router: router,
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Data Fan'), findsWidgets);
    expect(find.text('fan@example.com'), findsWidgets);
  });

  testWidgets('navigates to change password from profile', (tester) async {
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/change-password',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
      ],
    );

    await pumpRouterApp(
      tester,
      router: router,
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change Password'));
    await tester.pumpAndSettle();

    expect(find.byType(ChangePasswordScreen), findsOneWidget);
  });
}
