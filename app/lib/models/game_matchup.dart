class GameMatchup {
  // --- List View Data (Basic Info) ---
  final int gameId;
  final DateTime gameTime;
  final String homeTeamName;
  final String awayTeamName;
  final String homeTeamAbbr;
  final String awayTeamAbbr;

  // --- Detail View Data (Predictions & Odds) ---
  final String predictedWinner;
  final double predictedProbability;
  final double confidencePrediction;
  final double valueBet;

  // --- Detail View Data (Stats) ---
  final Map<String, String> homeStats;
  final Map<String, String> awayStats;

  GameMatchup({
    required this.gameId,
    required this.gameTime,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeTeamAbbr,
    required this.awayTeamAbbr,
    required this.predictedWinner,
    required this.predictedProbability,
    required this.confidencePrediction,
    required this.valueBet,
    required this.homeStats,
    required this.awayStats,
  });

  // Eventually need a factory constructor to parse the real API JSON
  // This is a blueprint for that:

  //   factory GameMatchup.fromJson(Map<String, dynamic> json) {
  //     return GameMatchup(
  //       gameId: json['id'] ?? 0,
  //       homeTeamName: json['homeTeamName'] ?? 'Unknown',
  //       homeTeamAbbr: json['homeTeamAbbr'] ?? 'UNK',
  //       awayTeamName: json['awayTeamName'] ?? 'Unknown',
  //       awayTeamAbbr: json['awayTeamAbbr'] ?? 'UNK',
  //       gameTime: json['gameTime'] != null 
  //           ? DateTime.parse(json['gameTime']) 
  //           : DateTime.now(),
  //     );
  //   }
  // }
}