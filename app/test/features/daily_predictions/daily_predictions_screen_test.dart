import 'dart:async';

import 'package:app/features/daily_predictions/presentation/providers/prediction_provider.dart';
import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart';
import 'package:app/models/game_matchup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';
import '../../support/mocks.dart';
import '../../support/pump_app.dart';

void main() {
  late MockPredictionRepository mockPredictionRepository;

  setUp(() {
    mockPredictionRepository = MockPredictionRepository();
  });

  testWidgets('shows a loading indicator while predictions load', (
      tester,
      ) async {
    final completer = Completer<List<GameMatchup>>();
    when(
          () => mockPredictionRepository.fetchDailyGames(),
    ).thenAnswer((_) => completer.future);

    await pumpWidgetApp(
      tester,
      child: const DailyPredictionsPage(),
      overrides: [
        predictionRepositoryProvider.overrideWithValue(
          mockPredictionRepository,
        ),
      ],
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders an error state when the repository throws', (
      tester,
      ) async {
    when(
          () => mockPredictionRepository.fetchDailyGames(),
    ).thenThrow(Exception('network unavailable'));

    await pumpWidgetApp(
      tester,
      child: const DailyPredictionsPage(),
      overrides: [
        predictionRepositoryProvider.overrideWithValue(
          mockPredictionRepository,
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('network unavailable'), findsOneWidget);
  });

  testWidgets('renders multiple games from the repository', (tester) async {
    when(() => mockPredictionRepository.fetchDailyGames()).thenAnswer(
          (_) async => [
        buildGameMatchup(gameId: 'game-1', homeTeamName: 'Cardinals'),
        buildGameMatchup(
          gameId: 'game-2',
          homeTeamName: 'Yankees',
          homeTeamId: '147',
          awayTeamName: 'Red Sox',
          awayTeamId: '111',
          predictedWinner: 'Yankees',
        ),
      ],
    );

    await pumpWidgetApp(
      tester,
      child: const DailyPredictionsPage(),
      overrides: [
        predictionRepositoryProvider.overrideWithValue(
          mockPredictionRepository,
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.byType(GameListItem), findsNWidgets(2));
    expect(find.text('NYY'), findsWidgets);
    expect(find.text('BOS'), findsWidgets);
  });

  testWidgets('falls back to text when a team logo asset is missing', (
      tester,
      ) async {
    when(() => mockPredictionRepository.fetchDailyGames()).thenAnswer(
          (_) async => [
        buildGameMatchup(
          homeTeamId: 'HOMELESS',
          awayTeamId: 'AWAYLESS',
          homeTeamName: 'Home Team',
          awayTeamName: 'Away Team',
          predictedWinner: 'Home Team',
        ),
      ],
    );

    await pumpWidgetApp(
      tester,
      child: const DailyPredictionsPage(),
      overrides: [
        predictionRepositoryProvider.overrideWithValue(
          mockPredictionRepository,
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('HOMELESS'), findsWidgets);
    expect(find.text('AWAYLESS'), findsWidgets);
  });

  // UPDATED: Now looks for the unified "VALUE EDGE DETECTED" string
  testWidgets('shows the value edge badge for strong positive-odds edges', (
      tester,
      ) async {
    when(
          () => mockPredictionRepository.fetchDailyGames(),
    ).thenAnswer((_) async => [buildGameMatchup(odds: 140, confidence: 72)]);

    await pumpWidgetApp(
      tester,
      child: const DailyPredictionsPage(),
      overrides: [
        predictionRepositoryProvider.overrideWithValue(
          mockPredictionRepository,
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('VALUE EDGE DETECTED'), findsOneWidget);
  });

  // UPDATED: Now looks for the unified "VALUE EDGE DETECTED" string
  testWidgets('shows the value edge badge for smaller positive-odds edges', (
      tester,
      ) async {
    when(
          () => mockPredictionRepository.fetchDailyGames(),
    ).thenAnswer((_) async => [buildGameMatchup(odds: 115, confidence: 55)]);

    await pumpWidgetApp(
      tester,
      child: const DailyPredictionsPage(),
      overrides: [
        predictionRepositoryProvider.overrideWithValue(
          mockPredictionRepository,
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('VALUE EDGE DETECTED'), findsOneWidget);
  });

  testWidgets('does not show a value badge for negative odds', (tester) async {
    when(
          () => mockPredictionRepository.fetchDailyGames(),
    ).thenAnswer((_) async => [buildGameMatchup(odds: -120)]);

    await pumpWidgetApp(
      tester,
      child: const DailyPredictionsPage(),
      overrides: [
        predictionRepositoryProvider.overrideWithValue(
          mockPredictionRepository,
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('VALUE EDGE DETECTED'), findsNothing);
  });
}