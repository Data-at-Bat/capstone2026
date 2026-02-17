import '../models/game_matchup.dart';

class GameRepository {
  // Toggle this when the backend API is stood up
  final bool _useMockData = true;

  Future<List<GameMatchup>> fetchDailyGames() async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        GameMatchup(
          gameId: 1,
          homeTeamName: "Los Angeles Dodgers",
          homeTeamAbbr: "LAD",
          awayTeamName: "New York Yankees",
          awayTeamAbbr: "NYY",
          gameTime: DateTime.now().add(const Duration(hours: 2)),
        ),
        GameMatchup(
          gameId: 2,
          homeTeamName: "St. Louis Cardinals",
          homeTeamAbbr: "STL",
          awayTeamName: "Chicago Cubs",
          awayTeamAbbr: "CHC",
          gameTime: DateTime.now().add(const Duration(hours: 5)),
        ),
      ];
    } else {
      // Future API Call: return http.get(...)
      throw UnimplementedError("API integration pending");
    }
  }
}