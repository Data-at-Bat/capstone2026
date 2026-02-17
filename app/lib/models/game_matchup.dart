class GameMatchup {
  final int gameId;
  final String homeTeamName;
  final String homeTeamAbbr;
  final String awayTeamName;
  final String awayTeamAbbr;
  final DateTime gameTime;

  GameMatchup({
    required this.gameId,
    required this.homeTeamName,
    required this.homeTeamAbbr,
    required this.awayTeamName,
    required this.awayTeamAbbr,
    required this.gameTime,
  });

  // Factory constructor to handle future JSON from Spring Boot
  factory GameMatchup.fromJson(Map<String, dynamic> json) {
    return GameMatchup(
      gameId: json['id'] ?? 0,
      homeTeamName: json['homeTeamName'] ?? 'Unknown',
      homeTeamAbbr: json['homeTeamAbbr'] ?? 'UNK',
      awayTeamName: json['awayTeamName'] ?? 'Unknown',
      awayTeamAbbr: json['awayTeamAbbr'] ?? 'UNK',
      gameTime: json['gameTime'] != null 
          ? DateTime.parse(json['gameTime']) 
          : DateTime.now(),
    );
  }
}