// import 'package:flutter/material.dart';

// class DailyPredictionsPage extends StatelessWidget {
//   const DailyPredictionsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(child: Text('Daily Predictions'));
//   }
// }
import 'package:flutter/material.dart';
import 'package:app/shared/logging/logger_service.dart';

// --- DATA MODEL ---
class GameMatchup {
  final String homeTeamName;
  final String homeTeamAbbr; // Must match the filename in assets/logos/
  final String awayTeamName;
  final String awayTeamAbbr; // Must match the filename in assets/logos/
  final DateTime gameTime;
  final int gameId; // Unique identifier for logging purposes

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

  // --- PLACEHOLDER DATA USING YOUR PROJECT COLORS ---
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
      backgroundColor: const Color(0xFFC6DDF0), // Light Blue [User Prompt]
      appBar: AppBar(
        title: const Text('Daily Predictions'),
        backgroundColor: const Color(0xFF462255), // Dark Purple [User Prompt]
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Log navigation event per project requirements
          try {
            // Navigation logic here
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
                  _buildTeamDisplay(game.awayTeamName, game.awayTeamAbbr, const Color(0xFFED6A5A)), // Coral
                  const Text("AT", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                  _buildTeamDisplay(game.homeTeamName, game.homeTeamAbbr, const Color(0xFF2374AB)), // Blue
                ],
              ),
              const Divider(height: 30, indent: 20, endIndent: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Color(0xFF143109)), // Dark Green
                  const SizedBox(width: 8),
                  Text(
                    "Start Time: ${game.gameTime.hour}:${game.gameTime.minute.toString().padLeft(2, '0')} PM",
                    style: const TextStyle(color: Color(0xFF143109), fontWeight: FontWeight.bold),
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
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: circleColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/logos/$abbr.png',
              fit: BoxFit.contain,
              // Fallback if the PNG isn't found or is corrupted
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.sports_baseball, color: Colors.white, size: 30),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(abbr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}