import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/models/game_matchup.dart';
import 'package:app/repositories/game_repository.dart';
import 'package:app/shared/logging/logger_service.dart';
import 'package:app/features/daily_predictions/presentation/screens/game_detail_screen.dart';

class DailyPredictionsPage extends StatelessWidget {
  final GameRepository repository;
  final bool isUserPaid = false; // Placeholder for subscription logic

  const DailyPredictionsPage({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC6DDF0), // Original Light Blue
      appBar: AppBar(
        title: const Text('Daily Predictions'),
        backgroundColor: const Color(0xFF462255), // Original Dark Purple
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<GameMatchup>>(
        future: repository.fetchDailyGames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF462255)),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final games = snapshot.data ?? [];
          if (games.isEmpty) {
            return const Center(child: Text("No games found for today."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: games.length,
            itemBuilder: (context, index) => GameListItem(
              game: games[index],
              isPaid: isUserPaid,
            ),
          );
        },
      ),
    );
  }
}

class GameListItem extends StatelessWidget {
  final GameMatchup game;
  final bool isPaid;

  const GameListItem({super.key, required this.game, required this.isPaid});

  @override
  Widget build(BuildContext context) {
    final String formattedTime = DateFormat.jm().format(game.gameTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4, // Original Elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          try {
            LoggerService.logEvent(
              fileName: 'daily_predictions_screen.dart',
              functionName: 'onGameClicked(${game.gameId})',
              outcome: 'Success',
            );
            
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GameDetailPage(game: game)),
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
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10), // Original Padding
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTeamDisplay(game.awayTeamName, game.awayTeamAbbr, const Color(0xFFED6A5A)), // Coral
                  const Text(
                    "AT",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  _buildTeamDisplay(game.homeTeamName, game.homeTeamAbbr, const Color(0xFF2374AB)), // Blue
                ],
              ),
              
              // Only show the Divider and Time if it's a standard view or paid view
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

              // Value Bet Indicator for Non-Paid users
              if (!isPaid) ...[
                const SizedBox(height: 10),
                _blurredValueBet(),
              ],
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
          radius: 35, // Original Radius
          backgroundColor: circleColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/logos/$abbr.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.sports_baseball, color: Colors.white, size: 30),
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

  Widget _blurredValueBet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "Premium Content Hidden",
        style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black54),
      ),
    );
  }
}