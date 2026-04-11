import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/profile/presentation/screens/profile_screen.dart';
import 'package:app/features/subscription/presentation/screens/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/mocks.dart';
import '../../support/pump_app.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
  });

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    );
  }

  testWidgets('navigates to profile from settings', (tester) async {
    await pumpRouterApp(
      tester,
      router: buildRouter(),
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile Information'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('does not sign out when logout is cancelled', (tester) async {
    await pumpRouterApp(
      tester,
      router: buildRouter(),
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => mockAuthRepository.signOut());
  });

  testWidgets('signs out when logout is confirmed', (tester) async {
    await pumpRouterApp(
      tester,
      router: buildRouter(),
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Out').last);
    await tester.pumpAndSettle();

    verify(() => mockAuthRepository.signOut()).called(1);
  });
}
