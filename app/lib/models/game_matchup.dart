class GameMatchup {
  final String gameId;
  final DateTime gameTime;
  final String homeTeamID;
  final String? homeTeamName;
  final String awayTeamID;
  final String? awayTeamName;
  final String? predictedWinner;
  final double? confidence;
  final double? spread;
  final double? odds;
  final List<String>? predictiveFactors;

  GameMatchup({
    required this.gameId,
    required this.gameTime,
    required this.homeTeamID,
    this.homeTeamName,
    required this.awayTeamID,
    this.awayTeamName,
    this.predictedWinner,
    this.confidence,
    this.spread,
    this.odds,
    this.predictiveFactors,
  });

  factory GameMatchup.fromJson(Map<String, dynamic> json) {

    try {
      return GameMatchup(
        gameId: json['gameId'] as String,
        gameTime: DateTime.parse(json['gameTime'] as String),
        homeTeamID: json['homeTeamId'] as String,
        homeTeamName: json['homeTeamName'] as String?,
        awayTeamID: json['awayTeamId'] as String,
        awayTeamName: json['awayTeamName'] as String?,
        predictedWinner: json['predictedWinner'] as String?,
        confidence: (json['confidence'] as num?)?.toDouble(),
        spread: (json['spread'] as num?)?.toDouble(),
        odds: (json['odds'] as num?)?.toDouble(),
        predictiveFactors: (json['predictiveFactors'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
      );
    } catch (e) {
      rethrow;
    }
  }
}