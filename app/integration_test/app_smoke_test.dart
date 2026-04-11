import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/auth/presentation/screens/change_password_screen.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart';
import 'package:app/features/daily_predictions/presentation/providers/prediction_provider.dart';
import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart';
import 'package:app/features/daily_predictions/presentation/screens/game_detail_screen.dart';
import 'package:app/main.dart';
import 'package:app/shared/router/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import '../test/support/fixtures.dart';
import '../test/support/mocks.dart';
import '../test/support/pump_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pumpMyApp(
    WidgetTester tester, {
    required User? authUser,
    required MockPredictionRepository predictionRepository,
    String? displayName,
    String? email,
  }) async {
    final user = authUser is MockUser ? authUser : null;
    if (user != null) {
      when(() => user.displayName).thenReturn(displayName);
      when(() => user.email).thenReturn(email);
    }

    final container = createContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(authUser)),
        predictionRepositoryProvider.overrideWithValue(predictionRepository),
      ],
    );

    await pumpWithContainer(tester, container: container, child: const MyApp());
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('unauthenticated launch lands on login', (tester) async {
    final predictionRepository = MockPredictionRepository();
    when(
      () => predictionRepository.fetchDailyGames(),
    ).thenAnswer((_) async => []);

    await pumpMyApp(
      tester,
      authUser: null,
      predictionRepository: predictionRepository,
    );

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets(
    'login route redirects into the main shell for authenticated users',
    (tester) async {
      final predictionRepository = MockPredictionRepository();
      when(
        () => predictionRepository.fetchDailyGames(),
      ).thenAnswer((_) async => [buildGameMatchup()]);
      final user = MockUser();

      final container = await pumpMyApp(
        tester,
        authUser: user,
        predictionRepository: predictionRepository,
      );

      container.read(routerProvider).go('/login');
      await tester.pumpAndSettle();

      expect(find.byType(DailyPredictionsPage), findsOneWidget);
    },
  );

  testWidgets('can navigate between predictions and settings', (tester) async {
    final predictionRepository = MockPredictionRepository();
    when(
      () => predictionRepository.fetchDailyGames(),
    ).thenAnswer((_) async => [buildGameMatchup()]);
    final user = MockUser();

    await pumpMyApp(
      tester,
      authUser: user,
      predictionRepository: predictionRepository,
      displayName: 'Data Fan',
      email: 'fan@example.com',
    );

    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.list_alt));
    await tester.pumpAndSettle();
    expect(find.byType(DailyPredictionsPage), findsOneWidget);
  });

  testWidgets('can open a game detail from the predictions list', (
    tester,
  ) async {
    final predictionRepository = MockPredictionRepository();
    when(
      () => predictionRepository.fetchDailyGames(),
    ).thenAnswer((_) async => [buildGameMatchup()]);
    final user = MockUser();

    await pumpMyApp(
      tester,
      authUser: user,
      predictionRepository: predictionRepository,
    );

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    expect(find.byType(GameDetailScreen), findsOneWidget);
  });

  testWidgets('can open profile and navigate to change password', (
    tester,
  ) async {
    final predictionRepository = MockPredictionRepository();
    when(
      () => predictionRepository.fetchDailyGames(),
    ).thenAnswer((_) async => [buildGameMatchup()]);
    final user = MockUser();

    await pumpMyApp(
      tester,
      authUser: user,
      predictionRepository: predictionRepository,
      displayName: 'Data Fan',
      email: 'fan@example.com',
    );

    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile Information'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change Password'));
    await tester.pumpAndSettle();

    expect(find.byType(ChangePasswordScreen), findsOneWidget);
  });
}
