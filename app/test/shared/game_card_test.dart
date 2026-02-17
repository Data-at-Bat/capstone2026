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
      gameId: 42,
      homeTeamName: "Dodgers", homeTeamAbbr: "LAD",
      awayTeamName: "Yankees", awayTeamAbbr: "NYY",
      gameTime: DateTime.now(),
    );

    when(() => mockRepo.fetchDailyGames()).thenAnswer((_) async => [game]);

    await tester.pumpWidget(MaterialApp(
      home: DailyPredictionsPage(repository: mockRepo),
    ));
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