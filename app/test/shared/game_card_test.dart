import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/game_matchup.dart';
import 'package:app/features/daily_predictions/data/repositories/prediction_repository.dart';
import 'package:app/features/daily_predictions/presentation/providers/prediction_provider.dart';
import 'package:app/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart';

class MockPredictionRepository extends Mock implements PredictionRepository {}

void main() {
  late MockPredictionRepository mockRepo;

  setUp(() {
    mockRepo = MockPredictionRepository();
  });

  testWidgets('Behavioral: Tapping game card navigates to detail view', (tester) async {
    final game = GameMatchup(
      gameId: 42,
      homeTeamName: "Dodgers", homeTeamAbbr: "LAD",
      awayTeamName: "Yankees", awayTeamAbbr: "NYY",
      gameTime: DateTime.now(),
    );

    when(() => mockRepo.fetchDailyGames()).thenAnswer((_) async => [game]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          predictionRepositoryProvider.overrideWithValue(mockRepo),
          // Assume user is subscribed to avoid redirection for simplicity
          subscriptionStateProvider.overrideWith((ref) => Stream.value(true)),
        ],
        child: const MaterialApp(
          home: DailyPredictionsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Display
    expect(find.text('LAD'), findsOneWidget);

    // Verify Interaction
    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    // Verify Selection Outcome (Navigated to Detail Page)
    expect(find.textContaining('Model Prediction for Game 42'), findsOneWidget);
  });
}
