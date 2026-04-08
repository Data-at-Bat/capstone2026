import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app/models/game_matchup.dart';
import 'package:app/features/daily_predictions/presentation/providers/prediction_provider.dart';
import 'package:app/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:app/shared/logging/logger_service.dart';
import 'package:app/features/daily_predictions/presentation/screens/game_detail_screen.dart';

class DailyPredictionsPage extends ConsumerWidget {
  const DailyPredictionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Very light, cool-grey background
      appBar: AppBar(
        title: const Text('Daily Predictions', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF462255), // Signature Dark Purple
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<GameMatchup>>(
        future: repository.fetchDailyGames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF462255)),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }

          final games = snapshot.data ?? [];
          if (games.isEmpty) {
            return const Center(child: Text("No games found for today.", style: TextStyle(fontSize: 16, color: Colors.grey)));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: games.length,
            itemBuilder: (context, index) => GameListItem(
              game: games[index],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF462255)),
        ),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}

class GameListItem extends StatelessWidget {
  final GameMatchup game;

  const GameListItem({super.key, required this.game});

  // Translates MLB API Numeric IDs to your abbreviations
  String _getAbbreviation(String teamId) {
    const Map<String, String> idMap = {
      '108': 'LAA', '109': 'ARI', '110': 'BAL', '111': 'BOS', '112': 'CHC',
      '113': 'CIN', '114': 'CLE', '115': 'COL', '116': 'DET', '117': 'HOU',
      '118': 'KC',  '119': 'LAD', '120': 'WSH', '121': 'NYM', '133': 'OAK',
      '134': 'PIT', '135': 'SD',  '136': 'SEA', '137': 'SF',  '138': 'STL',
      '139': 'TB',  '140': 'TEX', '141': 'TOR', '142': 'MIN', '143': 'PHI',
      '144': 'ATL', '145': 'CWS', '146': 'MIA', '147': 'NYY', '158': 'MIL',
    };
    return idMap[teamId] ?? teamId; // Fallback to the ID if not found
  }

  // Reused from Detail Screen for cohesive design
  Color _getTeamColor(String teamAbbr) {
    switch (teamAbbr.toUpperCase()) {
    // --- AL EAST ---
      case 'BAL': return const Color(0xFFDF4601);
      case 'BOS': return const Color(0xFFBD3039);
      case 'NYY': return const Color(0xFF003087);
      case 'TB':  return const Color(0xFF092C5C);
      case 'TOR': return const Color(0xFF134A8E);

    // --- AL CENTRAL ---
      case 'CWS': return const Color(0xFF27251F);
      case 'CLE': return const Color(0xFFE31937);
      case 'DET': return const Color(0xFF0C2340);
      case 'KC':  return const Color(0xFF004687);
      case 'MIN': return const Color(0xFF002B5C);

    // --- AL WEST ---
      case 'HOU': return const Color(0xFFEB6E1F);
      case 'LAA': return const Color(0xFFBA0021);
      case 'OAK': return const Color(0xFF003831);
      case 'SEA': return const Color(0xFF005C5C);
      case 'TEX': return const Color(0xFF003278);

    // --- NL EAST ---
      case 'ATL': return const Color(0xFFCE1141);
      case 'MIA': return const Color(0xFF00A3E0);
      case 'NYM': return const Color(0xFFFF5910);
      case 'PHI': return const Color(0xFFE81828);
      case 'WSH': return const Color(0xFFAB0003);

    // --- NL CENTRAL ---
      case 'CHC': return const Color(0xFF0E3386);
      case 'CIN': return const Color(0xFFC6011F);
      case 'MIL': return const Color(0xFF12284B);
      case 'PIT': return const Color(0xFFFDB827);
      case 'STL': return const Color(0xFFC41E3A);

    // --- NL WEST ---
      case 'ARI': return const Color(0xFFA71930);
      case 'COL': return const Color(0xFF33006F);
      case 'LAD': return const Color(0xFF005A9C);
      case 'SD':  return const Color(0xFF2F241D);
      case 'SF':  return const Color(0xFFFD5A1E);

    // --- FALLBACK ---
      default: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedTime = DateFormat.jm().format(game.gameTime);

    // FIX: Removed the redundant '!= null' checks since these are non-nullable doubles
    // If odds are positive (e.g. +110), the model is picking an underdog = Value Bet!
    bool isTrueValueBet = game.odds > 0;

    // If confidence is high AND it's an underdog, it's a LARGE value bet
    bool isTrueLargeValue = isTrueValueBet && game.confidence >= 65.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            try {
              LoggerService.logEvent(
                fileName: 'daily_predictions_screen.dart',
                functionName: 'onGameClicked(${game.gameId})',
                outcome: 'Success',
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameDetailScreen(
                    gameData: game,
                    userId: '',
                  ),
                ),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Start Time Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.schedule, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      formattedTime,
                      style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Matchup Row with Dynamic Colors
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _buildTeamDisplay(game.awayTeamId, game.awayTeamName)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("AT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.grey)),
                    ),
                    Expanded(child: _buildTeamDisplay(game.homeTeamId, game.homeTeamName)),
                  ],
                ),

                // Value Bet Indicator
                if (isTrueValueBet) ...[
                  const SizedBox(height: 24),
                  _buildValueBetArea(isLargeEdge: isTrueLargeValue),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamDisplay(String teamId, String? teamName) {
    // Translate the numeric ID to the abbreviation (e.g., "138" -> "STL")
    String teamAbbr = _getAbbreviation(teamId);
    Color teamColor = _getTeamColor(teamAbbr);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [teamColor.withValues(alpha: 0.1), teamColor.withValues(alpha: 0.25)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              'assets/logos/$teamAbbr.png', // Request the abbreviation format
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Center(child: Text(teamAbbr, style: TextStyle(fontWeight: FontWeight.bold, color: teamColor))),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          teamAbbr, // Display abbreviation instead of numeric ID
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black87),
        ),
        if (teamName != null)
          Text(
            teamName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
      ],
    );
  }

  // Refactored method: No more locks. Only displays if a value bet is found.
  Widget _buildValueBetArea({required bool isLargeEdge}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isLargeEdge ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isLargeEdge ? Colors.green.shade300 : Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLargeEdge ? Icons.local_fire_department : Icons.trending_up,
            color: isLargeEdge ? Colors.green : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isLargeEdge ? "LARGE VALUE EDGE" : "VALUE PICK",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isLargeEdge ? Colors.green[700] : Colors.blue[700],
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
