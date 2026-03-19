import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/models/game_matchup.dart';
import 'package:app/repositories/game_repository.dart';
import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart';

class MockGameRepository extends Mock implements GameRepository {}

void main() {
  late MockGameRepository mockRepo;

  // This is our perfect mock game based on the updated backend schema
  final mockGame = GameMatchup(
    gameId: '04b61be4-0d94-403d-aefb-ccaa1d404f99', // uuid in the db
    gameTime: DateTime.parse('2026-03-18 19:45:00'),
    homeTeamId: 'STL',
    homeTeamName: 'St. Louis Cardinals',
    awayTeamId: 'CHC',
    awayTeamName: 'Chicago Cubs',
    predictedWinner: 'STL',
    confidence: 68.5,
    odds: -130.0,
    spread: -1.5,
    predictiveFactors: ['Strong offense', 'Weak opponent pitching'],
  );

  setUp(() {
    mockRepo = MockGameRepository();
  });

  group('Daily Predictions Page Tests', () {

    testWidgets('Renders empty state when no games are returned', (tester) async {
      // Tell the mock repository to return an empty list
      when(() => mockRepo.fetchDailyGames()).thenAnswer((_) async => []);

      await tester.pumpWidget(MaterialApp(
        home: DailyPredictionsPage(repository: mockRepo),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Start Time:'), findsNothing);
    });

    testWidgets('Renders game cards successfully', (tester) async {
      when(() => mockRepo.fetchDailyGames()).thenAnswer((_) async => [mockGame]);

      await tester.pumpWidget(MaterialApp(
        home: DailyPredictionsPage(repository: mockRepo),
      ));

      await tester.pumpAndSettle();

      // Verify that the team abbreviations (or names) actually rendered on the screen
      expect(find.text('STL'), findsWidgets);
      expect(find.text('CHC'), findsWidgets);
    });

    testWidgets('Behavioral: Tapping game card navigates to detail view', (tester) async {
      when(() => mockRepo.fetchDailyGames()).thenAnswer((_) async => [mockGame]);

      await tester.pumpWidget(MaterialApp(
        home: DailyPredictionsPage(repository: mockRepo), // Note: Ensure this passes userId/isPaidMember down to the DetailScreen
      ));

      // Wait for the FutureBuilder to finish its mock fetch and build the list
      await tester.pumpAndSettle();

      // Find the card/InkWell and tap it
      await tester.tap(find.byType(InkWell).first);

      // Wait for the Navigator.push page transition animation to finish
      await tester.pumpAndSettle();

      // Verify the specific text from our updated GameDetailScreen is present
      expect(find.textContaining('Predicted Winner: STL'), findsOneWidget);
      expect(find.textContaining('Model Confidence: 68.5%'), findsOneWidget);
    });
  });
}