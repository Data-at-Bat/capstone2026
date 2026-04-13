import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/models/game_matchup.dart';
import 'package:app/features/daily_predictions/data/repositories/prediction_repository.dart';
import 'package:app/features/daily_predictions/presentation/providers/prediction_provider.dart';
import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart';
import 'package:app/features/daily_predictions/presentation/screens/game_detail_screen.dart';
import 'package:app/features/profile/presentation/providers/favorites_provider.dart';

class MockPredictionRepository extends Mock implements PredictionRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockPredictionRepository mockRepo;

  final mockGame = GameMatchup(
    gameId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    gameTime: DateTime.now().add(const Duration(hours: 2)),
    homeTeamName: 'St. Louis Cardinals',
    awayTeamName: 'Chicago Cubs',
    homeTeamId: '138',
    awayTeamId: '112',
    predictedWinner: 'St. Louis Cardinals',
    confidence: 80.0,
    odds: 150.0,
    spread: -2.0,
    predictiveFactors: {
      'home_ops': 0.768,
      'away_ops': 0.636,
      'home_pitching_era': 3.53,
      'away_pitching_era': 4.71,
    },
  );

  setUp(() {
    mockRepo = MockPredictionRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        predictionRepositoryProvider.overrideWithValue(mockRepo),
        // Mocked favorites provider to instantly return an empty set
        favoritesProvider.overrideWith((ref) async => <String>{}),
      ],
      child: const MaterialApp(home: DailyPredictionsPage()),
    );
  }

  group('Daily Predictions Page Tests', () {
    testWidgets('Renders empty state when no games are returned', (
        tester,
        ) async {
      when(() => mockRepo.fetchDailyGames()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('No games found for today.'), findsOneWidget);
    });

    testWidgets('Renders game cards successfully', (tester) async {
      when(
            () => mockRepo.fetchDailyGames(),
      ).thenAnswer((_) async => [mockGame]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('STL'), findsWidgets);
      expect(find.text('CHC'), findsWidgets);
    });

    testWidgets('Behavioral: Tapping game card navigates to detail view', (
        tester,
        ) async {
      when(
            () => mockRepo.fetchDailyGames(),
      ).thenAnswer((_) async => [mockGame]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Updated the tap target to strictly look for the GameListItem
      await tester.tap(find.byType(GameListItem).first);
      await tester.pumpAndSettle();

      // --- UI ASSERTIONS FOR THE DETAIL SCREEN ---
      expect(find.byType(GameDetailScreen), findsOneWidget);

      expect(
        find.text('Model Predicts: '),
        findsOneWidget,
      ); // Fixed text from UI code
      expect(find.text('St. Louis Cardinals'), findsWidgets);

      expect(find.text('80.0%'), findsOneWidget);
      expect(find.textContaining('-2'), findsOneWidget);

      expect(find.text('Key Predictive Factors'), findsOneWidget);

      expect(find.text('VALUE BET EDGE'), findsOneWidget);
      expect(find.textContaining('+150'), findsOneWidget);

      expect(find.text('Unlock Value Bets'), findsNothing);
    });
  });
}