import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../models/game_matchup.dart'; // Adjust path if needed

class GameDetailScreen extends StatelessWidget {
  final GameMatchup gameData;
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
    // Formatting the date nicely for the app bar
    String formattedDate = "${gameData.gameTime.month}/${gameData.gameTime.day}/${gameData.gameTime.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text('Matchup: $formattedDate'),
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
          // 1. Team Logos Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeamLogo(game.awayTeamID),
              const Text('vs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              _buildTeamLogo(game.homeTeamID),
            ],
          ),
          const SizedBox(height: 30),

          // 2. Predictive Factors List
          _buildPredictiveFactorsList(game.predictiveFactors),
          const SizedBox(height: 30),

          // 3. Prediction Card
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                Text(
                  'Predicted Winner: ${game.predictedWinner ?? "TBD"}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Model Confidence: ${game.confidence?.toStringAsFixed(1) ?? "--"}%\nSpread: ${game.spread != null ? (game.spread! > 0 ? "+${game.spread}" : game.spread.toString()) : "N/A"}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // 4. Value Bet Premium Section
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

  // Redesigned to handle the new List<String> format perfectly
  Widget _buildPredictiveFactorsList(List<String>? factors) {
    if (factors == null || factors.isEmpty) {
      return const Text("No predictive factors available for this game yet.",
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey));
    }

    return Column(
      children: [
        const Text(
            "Key Predictive Factors",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        const SizedBox(height: 12),
        ...factors.map((factor) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("• ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(
                child: Text(factor, style: const TextStyle(fontSize: 16, height: 1.3)),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildValueBetIndicator(bool isPaidMember, GameMatchup game) {
    // Safely format the odds (e.g., adding a "+" to positive numbers)
    String formattedOdds = "N/A";
    if (game.odds != null) {
      formattedOdds = game.odds! > 0 ? "+${game.odds}" : game.odds.toString();
    }

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
            'Model shows an edge on the current line.\nOdds: $formattedOdds',
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