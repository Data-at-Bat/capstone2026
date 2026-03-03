import '../models/game_matchup.dart'; 

class GameRepository {

  final bool _useMockData = true;
  // Fetches ALL games for the day, including deep stats and predictions
    Future<List<GameMatchup>> fetchDailyGames() async { // In the future there wll need to be userId and isPaidMember parameters to determine what data to return (blurred/unblurred)
      // Simulate network delay
      if (_useMockData) {
        await Future.delayed(const Duration(seconds: 2));

        // Mock response 
        return [
          GameMatchup(
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
          ),
          GameMatchup(
            gameId: 102,
            gameTime: DateTime.now().add(const Duration(hours: 5)),
            homeTeamName: 'Dodgers',
            awayTeamName: 'Giants',
            homeTeamAbbr: 'LAD',
            awayTeamAbbr: 'SF',
            predictedWinner: 'LAD',
            predictedProbability: 58.0,
            confidencePrediction: 72.0,
            valueBet: -110.0,
            homeStats: {
              'Batting Avg': '.265',
              'ERA': '3.15',
              'WHIP': '1.10',
            },
            awayStats: {
              'Batting Avg': '.235',
              'ERA': '3.90',
              'WHIP': '1.28',
            },
          ),
        ];
        } else {
          // Future API Call: return http.get(...)
          throw UnimplementedError("API integration pending");
    }
  }
}