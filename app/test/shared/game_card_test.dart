import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/models/game_matchup.dart';
import 'package:app/repositories/game_repository.dart';
import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart';

class MockGameRepository extends Mock implements GameRepository {}

void main() {
  late MockGameRepository mockRepo;

  setUp(() {
    mockRepo = MockGameRepository();
  });

testWidgets('Behavioral: Tapping game card navigates to detail view', (tester) async {
    final game = GameMatchup(
        gameId: 101,
        gameTime: DateTime.now().add(const Duration(hours: 2)),
        homeTeamName: 'Cardinals',
        awayTeamName: 'Cubs',
        homeTeamAbbr: 'STL',
        awayTeamAbbr: 'CHC',
        predictedWinner: 'STL',
        predictedProbability: 65.5,
        confidencePrediction: 80.0,
        valueBet: 150.0,
        homeStats: {
          'Batting Avg': '.255',
          'ERA': '3.45',
          'WHIP': '1.20',
        },
        awayStats: {
          'Batting Avg': '.240',
          'ERA': '4.10',
          'WHIP': '1.35',
        },
      );

    when(() => mockRepo.fetchDailyGames()).thenAnswer((_) async => [game]);

    await tester.pumpWidget(MaterialApp(
      home: DailyPredictionsPage(repository: mockRepo),
    ));

    // Wait for the FutureBuilder to finish its mock fetch and build the list
    await tester.pumpAndSettle();

    // Verify Interaction
    await tester.tap(find.byType(InkWell));
    
    // This pumpAndSettle waits for the Navigator.push page transition animation to finish
    await tester.pumpAndSettle(); 
    
    expect(find.text('Predicted Winner: STL'), findsOneWidget);
  });

}