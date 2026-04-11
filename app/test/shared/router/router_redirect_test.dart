import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart';
import 'package:app/features/daily_predictions/presentation/providers/prediction_provider.dart';
import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart';
import 'package:app/main.dart';
import 'package:app/shared/router/router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';
import '../../support/mocks.dart';
import '../../support/pump_app.dart';

void main() {
  testWidgets('redirects unauthenticated users to login for protected routes', (
    tester,
  ) async {
    final predictionRepository = MockPredictionRepository();
    when(() => predictionRepository.fetchDailyGames()).thenAnswer((_) async => []);
    final container = createContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(null)),
        predictionRepositoryProvider.overrideWithValue(predictionRepository),
      ],
    );

    await pumpWithContainer(
      tester,
      container: container,
      child: const MyApp(),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('redirects authenticated users away from login and signup', (
    tester,
  ) async {
    final mockUser = MockUser();
    final predictionRepository = MockPredictionRepository();
    when(
      () => predictionRepository.fetchDailyGames(),
    ).thenAnswer((_) async => [buildGameMatchup()]);
    final container = createContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
        predictionRepositoryProvider.overrideWithValue(predictionRepository),
      ],
    );
    final router = container.read(routerProvider);

    await pumpWithContainer(tester, container: container, child: const MyApp());
    await tester.pumpAndSettle();

    router.go('/login');
    await tester.pumpAndSettle();
    expect(find.byType(DailyPredictionsPage), findsOneWidget);

    router.go('/signup');
    await tester.pumpAndSettle();
    expect(find.byType(DailyPredictionsPage), findsOneWidget);
  });
}
