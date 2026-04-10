import 'package:app/models/game_matchup.dart';

GameMatchup buildGameMatchup({
  String gameId = 'game-1',
  DateTime? gameTime,
  String homeTeamName = 'St. Louis Cardinals',
  String awayTeamName = 'Chicago Cubs',
  String homeTeamId = '138',
  String awayTeamId = '112',
  String predictedWinner = 'St. Louis Cardinals',
  double confidence = 80.0,
  double odds = 150.0,
  double spread = -2.0,
  Map<String, dynamic>? predictiveFactors,
}) {
  return GameMatchup(
    gameId: gameId,
    gameTime: gameTime ?? DateTime(2026, 4, 9, 18, 5),
    homeTeamName: homeTeamName,
    awayTeamName: awayTeamName,
    homeTeamId: homeTeamId,
    awayTeamId: awayTeamId,
    predictedWinner: predictedWinner,
    confidence: confidence,
    odds: odds,
    spread: spread,
    predictiveFactors:
        predictiveFactors ??
        const {
          'home_ops': 0.768,
          'away_ops': 0.636,
          'home_pitching_era': 3.53,
          'away_pitching_era': 4.71,
        },
  );
}
