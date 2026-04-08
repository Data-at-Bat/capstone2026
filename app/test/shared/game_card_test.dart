import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/models/game_matchup.dart';
import 'package:app/repositories/game_repository.dart';
import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart';

class MockGameRepository extends Mock implements GameRepository {}

void main() {
  late MockGameRepository mockRepo;

  // Perfect mock game aligned with your backend and the specific test assertions
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
          'away_pitching_era': 4.71
        },
      );

  setUp(() {
    mockRepo = MockGameRepository();
  });

  group('Daily Predictions Page Tests', () {

    testWidgets('Renders empty state when no games are returned', (tester) async {
      when(() => mockRepo.fetchDailyGames()).thenAnswer((_) async => []);

      await tester.pumpWidget(MaterialApp(
        home: DailyPredictionsPage(repository: mockRepo),
      ));

      await tester.pumpAndSettle();

      // Asserts the exact empty state text from your updated UI
      expect(find.text('No games found for today.'), findsOneWidget);
    });

    testWidgets('Renders game cards successfully', (tester) async {
      when(() => mockRepo.fetchDailyGames()).thenAnswer((_) async => [mockGame]);

      await tester.pumpWidget(MaterialApp(
        home: DailyPredictionsPage(repository: mockRepo),
      ));

      await tester.pumpAndSettle();

      // Verify the team abbreviations render on the main list cards
      expect(find.text('STL'), findsWidgets);
      expect(find.text('CHC'), findsWidgets);
    });

    testWidgets('Behavioral: Tapping game card navigates to detail view', (tester) async {
      when(() => mockRepo.fetchDailyGames()).thenAnswer((_) async => [mockGame]);

      await tester.pumpWidget(MaterialApp(
        home: DailyPredictionsPage(repository: mockRepo),
      ));

      await tester.pumpAndSettle();

      // Tap the card to trigger navigation
      await tester.tap(find.byType(InkWell).first);

      // Wait for the Navigator.push page transition to finish
      await tester.pumpAndSettle();

      // --- UI ASSERTIONS FOR THE PREMIUM DETAIL SCREEN ---

      // Check the Model Pick Banner
      expect(find.text('Model Pick: '), findsOneWidget);
      expect(find.text('STL'), findsWidgets); // findsWidgets because STL is also in the top card

      // Check the Stat Badges
      expect(find.text('80.0%'), findsOneWidget);
      expect(find.textContaining('-2'), findsOneWidget);

      // Check the Predictive Factors list
      expect(find.text('home_pitching_era'), findsOneWidget);

      // Check the Premium lock indicator for unpaid users
      expect(find.text('Unlock Value Bets'), findsOneWidget);
    });
  });
}