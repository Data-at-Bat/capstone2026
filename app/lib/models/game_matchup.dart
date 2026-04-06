import 'dart:convert'; // <-- Required for jsonDecode

class GameMatchup {
  final String gameId;
  final DateTime gameTime;
  final String homeTeamId;
  final String? homeTeamName;
  final String awayTeamId;
  final String? awayTeamName;
  final String? predictedWinner;
  final double? confidence;
  final double? spread;
  final double? odds;
  final List<String>? predictiveFactors;

  GameMatchup({
    required this.gameId,
    required this.gameTime,
    required this.homeTeamId,
    this.homeTeamName,
    required this.awayTeamId,
    this.awayTeamName,
    this.predictedWinner,
    this.confidence,
    this.spread,
    this.odds,
    this.predictiveFactors,
  });

  factory GameMatchup.fromJson(Map<String, dynamic> json) {
    List<String>? parsedFactors;
    final factorsRaw = json['predictiveFactors'];

    if (factorsRaw != null) {
      if (factorsRaw is String) {
        // If the backend sends a stringified array (e.g. "[\"factor 1\"]")
        try {
          final decodedList = jsonDecode(factorsRaw) as List;
          parsedFactors = decodedList.map((e) => e.toString()).toList();
        } catch (e) {
          rethrow;
        }
      } else if (factorsRaw is List) {
        // If the backend sends a normal JSON array (e.g. ["factor 1"])
        parsedFactors = factorsRaw.map((e) => e.toString()).toList();
      }
    }

    // Return the safely parsed object
    try {
      return GameMatchup(
        gameId: json['gameId'] as String,
        gameTime: DateTime.parse(json['gameTime'] as String),
        homeTeamId: json['homeTeamId'] as String,
        homeTeamName: json['homeTeamName'] as String?,
        awayTeamId: json['awayTeamId'] as String,
        awayTeamName: json['awayTeamName'] as String?,
        predictedWinner: json['predictedWinner'] as String?,
        confidence: (json['confidence'] as num?)?.toDouble(),
        spread: (json['spread'] as num?)?.toDouble(),
        odds: (json['odds'] as num?)?.toDouble(),
        predictiveFactors: parsedFactors,
      );
    } catch (e) {
      rethrow;
    }
  }
}