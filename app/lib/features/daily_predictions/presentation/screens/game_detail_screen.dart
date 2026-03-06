import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../models/game_matchup.dart';

class GameDetailScreen extends StatelessWidget { // Can now be a stateless widget!
  final GameMatchup gameData; // Receives the full object
  final String userId;
  final bool isPaidMember;

  const GameDetailScreen({
    super.key,
    required this.gameData,
    required this.userId,
    required this.isPaidMember,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matchup Details: ${gameData.gameTime}'),
        centerTitle: true,
      ),
      body: _buildContent(gameData), 
    );
  }

  Widget _buildContent(GameMatchup game) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeamLogo(game.awayTeamAbbr),
              const Text('vs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _buildTeamLogo(game.homeTeamAbbr),
            ],
          ),
          const SizedBox(height: 30),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsColumn('Away (${game.awayTeamAbbr})', game.awayStats),
              _buildStatsColumn('Home (${game.homeTeamAbbr})', game.homeStats),
            ],
          ),
          const SizedBox(height: 40),

          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                Text(
                  'Predicted Winner: ${game.predictedWinner}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Win Probability: ${game.predictedProbability}%\nModel Confidence: ${game.confidencePrediction}%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          _buildValueBetIndicator(isPaidMember, game),
        ],
      ),
    );
  }

  Widget _buildTeamLogo(String teamAbbr) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/logos/$teamAbbr.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                teamAbbr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsColumn(String title, Map<String, String> stats) {
    String statsText = stats.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');

    return Expanded(
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Text(
            statsText,
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildValueBetIndicator(bool isPaidMember, GameMatchup game) {
    Widget valueBetContent = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            '🔥 VALUE BET INDICATOR',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
          ),
          const SizedBox(height: 12),
          Text(
            'Value Bet Differential: +${game.valueBet}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );

    if (isPaidMember) {
      return valueBetContent;
    } else {
      return Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: valueBetContent,
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.lock_open),
            label: const Text('Unlock Premium Insights'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
            ),
            onPressed: () {
              // TODO: Route to subscription screen
            },
          ),
        ],
      );
    }
  }
}