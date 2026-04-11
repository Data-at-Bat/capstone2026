import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app/models/game_matchup.dart';
import 'package:app/features/daily_predictions/presentation/providers/prediction_provider.dart';
import 'package:app/shared/logging/logger_service.dart';
import 'package:app/features/daily_predictions/presentation/screens/game_detail_screen.dart';

class DailyPredictionsPage extends ConsumerWidget {
  const DailyPredictionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsyncValue = ref.watch(dailyPredictionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA), // Brighter, cleaner background
      appBar: AppBar(
        title: const Text('Daily Predictions', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        backgroundColor: const Color(0xFF462255),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: gamesAsyncValue.when(
        data: (games) {
          if (games.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_baseball_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("No games found for today.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: games.length,
            itemBuilder: (context, index) => GameListItem(game: games[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF462255))),
        error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}

class GameListItem extends StatelessWidget {
  final GameMatchup game;

  const GameListItem({super.key, required this.game});

  String _getAbbreviation(String teamId) {
    const Map<String, String> idMap = {
      '108': 'LAA', '109': 'ARI', '110': 'BAL', '111': 'BOS', '112': 'CHC',
      '113': 'CIN', '114': 'CLE', '115': 'COL', '116': 'DET', '117': 'HOU',
      '118': 'KC',  '119': 'LAD', '120': 'WSH', '121': 'NYM', '133': 'OAK',
      '134': 'PIT', '135': 'SD',  '136': 'SEA', '137': 'SF',  '138': 'STL',
      '139': 'TB',  '140': 'TEX', '141': 'TOR', '142': 'MIN', '143': 'PHI',
      '144': 'ATL', '145': 'CWS', '146': 'MIA', '147': 'NYY', '158': 'MIL',
    };
    return idMap[teamId] ?? teamId;
  }

  Color _getTeamColor(String teamAbbr) {
    switch (teamAbbr.toUpperCase()) {
      case 'BAL': return const Color(0xFFDF4601); case 'BOS': return const Color(0xFFBD3039);
      case 'NYY': return const Color(0xFF003087); case 'TB':  return const Color(0xFF092C5C);
      case 'TOR': return const Color(0xFF134A8E); case 'CWS': return const Color(0xFF27251F);
      case 'CLE': return const Color(0xFFE31937); case 'DET': return const Color(0xFF0C2340);
      case 'KC':  return const Color(0xFF004687); case 'MIN': return const Color(0xFF002B5C);
      case 'HOU': return const Color(0xFFEB6E1F); case 'LAA': return const Color(0xFFBA0021);
      case 'OAK': return const Color(0xFF003831); case 'SEA': return const Color(0xFF005C5C);
      case 'TEX': return const Color(0xFF003278); case 'ATL': return const Color(0xFFCE1141);
      case 'MIA': return const Color(0xFF00A3E0); case 'NYM': return const Color(0xFFFF5910);
      case 'PHI': return const Color(0xFFE81828); case 'WSH': return const Color(0xFFAB0003);
      case 'CHC': return const Color(0xFF0E3386); case 'CIN': return const Color(0xFFC6011F);
      case 'MIL': return const Color(0xFF12284B); case 'PIT': return const Color(0xFFFDB827);
      case 'STL': return const Color(0xFFC41E3A); case 'ARI': return const Color(0xFFA71930);
      case 'COL': return const Color(0xFF33006F); case 'LAD': return const Color(0xFF005A9C);
      case 'SD':  return const Color(0xFF2F241D); case 'SF':  return const Color(0xFFFD5A1E);
      default: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formats to: "April 10, 7:00 PM"
    final String formattedDateTime = DateFormat('MMMM d, h:mm a').format(game.gameTime);

    // Any game with a positive edge is treated as a consistent value bet
    bool isValueBet = game.odds > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5)
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            try {
              LoggerService.logEvent(
                  fileName: 'daily_predictions_screen.dart',
                  functionName: 'onGameClicked(${game.gameId})',
                  outcome: 'Success'
              );
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameDetailScreen(gameData: game, userId: ''))
              );
            } catch (e) {
              LoggerService.logEvent(
                  fileName: 'daily_predictions_screen.dart',
                  functionName: 'onGameClicked',
                  outcome: 'Failure: ${e.toString()}'
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Top Row: Date and Time
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: const Color(0xFF462255).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Color(0xFF462255)),
                      const SizedBox(width: 8),
                      Text(
                          formattedDateTime,
                          style: const TextStyle(
                              color: Color(0xFF462255),
                              fontWeight: FontWeight.w800,
                              fontSize: 14
                          )
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Matchup Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildTeamDisplay(game.awayTeamId, game.awayTeamName, 'AWAY')),

                    // Stylish VS Badge
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Text("VS", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 12)),
                    ),

                    Expanded(child: _buildTeamDisplay(game.homeTeamId, game.homeTeamName, 'HOME')),
                  ],
                ),

                // Value Bet Banner (Consistently Green)
                if (isValueBet) ...[
                  const SizedBox(height: 24),
                  _buildValueBetArea(),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamDisplay(String teamId, String? teamName, String label) {
    String teamAbbr = _getAbbreviation(teamId);
    Color teamColor = _getTeamColor(teamAbbr);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Explicit Home/Away Label
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey.shade500)),
        const SizedBox(height: 12),

        // Larger Circle & Stronger Glow
        Container(
          width: 85,
          height: 85,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: teamColor.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 4
              )
            ],
            border: Border.all(color: teamColor.withValues(alpha: 0.2), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/logos/$teamAbbr.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Center(child: Text(teamAbbr, style: TextStyle(fontWeight: FontWeight.bold, color: teamColor))),
            ),
          ),
        ),

        const SizedBox(height: 16),
        Text(teamAbbr, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.black87)),
        if (teamName != null)
          Text(
            teamName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
      ],
    );
  }

  Widget _buildValueBetArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade400, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_fire_department, color: Colors.green.shade700, size: 20),
          const SizedBox(width: 8),
          Text(
            "VALUE EDGE DETECTED",
            style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.green.shade700,
                letterSpacing: 0.5,
                fontSize: 13
            ),
          ),
        ],
      ),
    );
  }
}