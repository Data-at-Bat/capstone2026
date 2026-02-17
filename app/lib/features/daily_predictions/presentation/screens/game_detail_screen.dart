import 'package:flutter/material.dart';
import '../../../../models/game_matchup.dart';

class GameDetailPage extends StatelessWidget {
  final GameMatchup game;

  const GameDetailPage({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${game.awayTeamAbbr} @ ${game.homeTeamAbbr}")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Model Prediction for Game ${game.gameId}", 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text("Advanced Stats and Analysis [API Data Pending]"),
          ],
        ),
      ),
    );
  }
}