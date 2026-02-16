import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/shared/logging/logger_service.dart';

// --- DATA MODEL ---
class GameMatchup {
  final String homeTeamName;
  final String homeTeamAbbr;
  final String awayTeamName;
  final String awayTeamAbbr;
  final DateTime gameTime;
  final int gameId;

  GameMatchup({
    required this.homeTeamName,
    required this.homeTeamAbbr,
    required this.awayTeamName,
    required this.awayTeamAbbr,
    required this.gameTime,
    required this.gameId,
  });
}

class DailyPredictionsPage extends StatelessWidget {
  DailyPredictionsPage({super.key});

  final List<GameMatchup> placeholderGames = [
    GameMatchup(
      homeTeamName: "Los Angeles Dodgers",
      homeTeamAbbr: "LAD",
      awayTeamName: "New York Yankees",
      awayTeamAbbr: "NYY",
      gameTime: DateTime.now().add(const Duration(hours: 2)),
      gameId: 1,
    ),
    GameMatchup(
      homeTeamName: "St. Louis Cardinals",
      homeTeamAbbr: "STL",
      awayTeamName: "Chicago Cubs",
      awayTeamAbbr: "CHC",
      gameTime: DateTime.now().add(const Duration(hours: 5)),
      gameId: 2,
    ),
    GameMatchup(
      homeTeamName: "Kansas City Royals",
      homeTeamAbbr: "KC",
      awayTeamName: "Detroit Tigers",
      awayTeamAbbr: "DET",
      gameTime: DateTime.now().add(const Duration(hours: 8)),
      gameId: 3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC6DDF0),
      appBar: AppBar(
        title: const Text('Daily Predictions'),
        backgroundColor: const Color(0xFF462255),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: placeholderGames.length,
        itemBuilder: (context, index) {
          return GameListItem(game: placeholderGames[index]);
        },
      ),
    );
  }
}

class GameListItem extends StatelessWidget {
  final GameMatchup game;
  const GameListItem({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final String formattedTime = DateFormat.jm().format(game.gameTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          try {
            LoggerService.logEvent(
              fileName: 'daily_predictions_screen.dart',
              functionName: 'onGameClicked(${game.gameId})',
              outcome: 'Success',
            );
          } catch (e) {
            LoggerService.logEvent(
              fileName: 'daily_predictions_screen.dart',
              functionName: 'onGameClicked',
              outcome: 'Failure: ${e.toString()}',
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildTeamDisplay(
                      game.awayTeamName,
                      game.awayTeamAbbr,
                      const Color(0xFFED6A5A),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "AT",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildTeamDisplay(
                      game.homeTeamName,
                      game.homeTeamAbbr,
                      const Color(0xFF2374AB),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30, indent: 20, endIndent: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFF143109),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Start Time: $formattedTime",
                    style: const TextStyle(
                      color: Color(0xFF143109),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamDisplay(String name, String abbr, Color circleColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: circleColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/logos/$abbr.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.sports_baseball,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          abbr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
