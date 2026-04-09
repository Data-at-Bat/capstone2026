import 'dart:convert';

class GameMatchup {
  final String gameId;
  final DateTime gameTime;
  final String homeTeamName;
  final String awayTeamName;
  final String homeTeamId;
  final String awayTeamId;
  final String predictedWinner;
  final double confidence;
  final double spread;
  final double odds;

  // 1. Change this from a List<String> to a Map<String, dynamic>
  final Map<String, dynamic> predictiveFactors;

  GameMatchup({
    required this.gameId,
    required this.gameTime,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.predictedWinner,
    required this.confidence,
    required this.spread,
    required this.odds,
    required this.predictiveFactors,
  });

  factory GameMatchup.fromJson(Map<String, dynamic> json) {

    // 2. Safely parse the predictiveFactors string back into a Map
    Map<String, dynamic> parsedFactors = {};
    if (json['predictiveFactors'] != null) {
      if (json['predictiveFactors'] is String) {
        // Unwraps the stringified JSON from Spring Boot
        parsedFactors = jsonDecode(json['predictiveFactors']);
      } else if (json['predictiveFactors'] is Map) {
        parsedFactors = Map<String, dynamic>.from(json['predictiveFactors']);
      }
    }

    return GameMatchup(
      gameId: json['gameId'] ?? '',
      gameTime: DateTime.parse(json['gameTime'] + 'Z').toLocal(),
      homeTeamName: json['homeTeamName'] ?? '',
      awayTeamName: json['awayTeamName'] ?? '',
      homeTeamId: json['homeTeamId'] ?? '',
      awayTeamId: json['awayTeamId'] ?? '',
      predictedWinner: json['predictedWinner'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      spread: (json['spread'] ?? 0.0).toDouble(),
      odds: (json['odds'] ?? 0.0).toDouble(),
      predictiveFactors: parsedFactors, // Pass the parsed map here
    );
  }
}