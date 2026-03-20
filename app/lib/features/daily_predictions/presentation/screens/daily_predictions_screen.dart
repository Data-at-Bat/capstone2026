import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/models/game_matchup.dart';
import 'package:app/repositories/game_repository.dart';
import 'package:app/shared/logging/logger_service.dart';
import 'package:app/features/daily_predictions/presentation/screens/game_detail_screen.dart';

class DailyPredictionsPage extends StatelessWidget {
  final GameRepository repository;
  // Placeholder: set to 'true' to test the paid view with value bet badges.
  final bool isUserPaid = false;

  const DailyPredictionsPage({super.key, required this.repository});

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

  // Reused from Detail Screen for cohesive design
  Color _getTeamColor(String teamId) {
    switch (teamId.toUpperCase()) {
    // --- AL EAST ---
      case 'BAL': return const Color(0xFFDF4601); // Orioles Orange
      case 'BOS': return const Color(0xFFBD3039); // Red Sox Red
      case 'NYY': return const Color(0xFF003087); // Yankees Navy
      case 'TB':  return const Color(0xFF092C5C); // Rays Navy
      case 'TOR': return const Color(0xFF134A8E); // Blue Jays Blue

    // --- AL CENTRAL ---
      case 'CWS': return const Color(0xFF27251F); // White Sox Black
      case 'CLE': return const Color(0xFFE31937); // Guardians Red
      case 'DET': return const Color(0xFF0C2340); // Tigers Navy
      case 'KC':  return const Color(0xFF004687); // Royals Blue
      case 'MIN': return const Color(0xFF002B5C); // Twins Navy

    // --- AL WEST ---
      case 'HOU': return const Color(0xFFEB6E1F); // Astros Orange
      case 'LAA': return const Color(0xFFBA0021); // Angels Red
      case 'OAK': return const Color(0xFF003831); // Athletics Green
      case 'SEA': return const Color(0xFF005C5C); // Mariners Northwest Green
      case 'TEX': return const Color(0xFF003278); // Rangers Blue

    // --- NL EAST ---
      case 'ATL': return const Color(0xFFCE1141); // Braves Red
      case 'MIA': return const Color(0xFF00A3E0); // Marlins Blue
      case 'NYM': return const Color(0xFFFF5910); // Mets Orange
      case 'PHI': return const Color(0xFFE81828); // Phillies Red
      case 'WSH': return const Color(0xFFAB0003); // Nationals Red

    // --- NL CENTRAL ---
      case 'CHC': return const Color(0xFF0E3386); // Cubs Blue
      case 'CIN': return const Color(0xFFC6011F); // Reds Red
      case 'MIL': return const Color(0xFF12284B); // Brewers Navy
      case 'PIT': return const Color(0xFFFDB827); // Pirates Gold
      case 'STL': return const Color(0xFFC41E3A); // Cardinals Red

    // --- NL WEST ---
      case 'ARI': return const Color(0xFFA71930); // Diamondbacks Sedona Red
      case 'COL': return const Color(0xFF33006F); // Rockies Purple
      case 'LAD': return const Color(0xFF005A9C); // Dodgers Blue
      case 'SD':  return const Color(0xFF2F241D); // Padres Brown
      case 'SF':  return const Color(0xFFFD5A1E); // Giants Orange

    // --- FALLBACK ---
      default: return Colors.blueGrey;            // Unknown/Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedTime = DateFormat.jm().format(game.gameTime);

    // Hidden Value Bet Logic for Paid users (needed for comparison)
    // If odds are positive (e.g. +110), the model is picking an underdog = Value Bet!
    bool isTrueValueBet = game.odds != null && game.odds! > 0;
    // If confidence is high AND it's an underdog, it's a LARGE value bet
    bool isTrueLargeValue = isTrueValueBet && game.confidence != null && game.confidence! >= 65.0;

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
                    isPaidMember: isPaid,
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

                // value Bet Indicator (MODIFIED LOGIC)
                const SizedBox(height: 24),
                _buildValueBetArea(isValueBetFound: isTrueValueBet, isLargeEdge: isTrueLargeValue),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamDisplay(String teamId, String? teamName) {
    Color teamColor = _getTeamColor(teamId);

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
              'assets/logos/$teamId.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Center(child: Text(teamId, style: TextStyle(fontWeight: FontWeight.bold, color: teamColor))),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          teamId,
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

  // Refactored method to handle the universal lock and specific paid badges
  Widget _buildValueBetArea({required bool isValueBetFound, required bool isLargeEdge}) {
    // If the user hasn't paid, universally show the lock for every game.
    if (!isPaid) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100, // Very neutral grey background
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 16, color: Colors.black87),
            const SizedBox(width: 6),
            Text(
              "Premium Edge Locked",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
          ],
        ),
      );
    }

    // Paid User View: Only build a badge if a value bet is actually found.
    if (!isValueBetFound) {
      return const SizedBox.shrink(); // Hide area if no value bet edge is detected for paid user
    }

    // specific styled badges for paid users
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
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:app/models/game_matchup.dart';
// import 'package:app/repositories/game_repository.dart';
// import 'package:app/shared/logging/logger_service.dart';
// import 'package:app/features/daily_predictions/presentation/screens/game_detail_screen.dart';
//
// class DailyPredictionsPage extends StatelessWidget {
//   final GameRepository repository;
//   final bool isUserPaid = false; // Placeholder for subscription logic
//
//   const DailyPredictionsPage({super.key, required this.repository});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFC6DDF0), // Original Light Blue
//       appBar: AppBar(
//         title: const Text('Daily Predictions'),
//         backgroundColor: const Color(0xFF462255), // Original Dark Purple
//         foregroundColor: Colors.white,
//     ),
//       body: FutureBuilder<List<GameMatchup>>(
//         future: repository.fetchDailyGames(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(color: Color(0xFF462255)),
//             );
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//
//           final games = snapshot.data ?? [];
//           if (games.isEmpty) {
//             return const Center(child: Text("No games found for today."));
//           }
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: games.length,
//             itemBuilder: (context, index) => GameListItem(
//               game: games[index],
//               isPaid: isUserPaid,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class GameListItem extends StatelessWidget {
//   final GameMatchup game;
//   final bool isPaid;
//
//   const GameListItem({super.key, required this.game, required this.isPaid});
//
//   @override
//   Widget build(BuildContext context) {
//     final String formattedTime = DateFormat.jm().format(game.gameTime);
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 4, // Original Elevation
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         onTap: () {
//           try {
//             LoggerService.logEvent(
//               fileName: 'daily_predictions_screen.dart',
//               functionName: 'onGameClicked(${game.gameId})',
//               outcome: 'Success',
//             );
//
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => GameDetailScreen(
//                   gameData: game,
//                   userId: '',
//                   isPaidMember: isPaid,
//                 ),
//               ),
//             );
//           } catch (e) {
//             LoggerService.logEvent(
//               fileName: 'daily_predictions_screen.dart',
//               functionName: 'onGameClicked',
//               outcome: 'Failure: ${e.toString()}',
//             );
//           }
//         },
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10), // Original Padding
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildTeamDisplay(
//                     // If awayTeamName is null, display the awayTeamId instead
//                       game.awayTeamName ?? "Unknown Away Team",
//                       game.awayTeamID,
//                       const Color(0xFFED6A5A)
//                   ), // Coral
//                   const Text(
//                     "AT",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
//                   ),
//                   _buildTeamDisplay(
//                     // If homeTeamName is null, display the homeTeamId instead
//                       game.homeTeamName ?? "Unknown Home Team",
//                       game.homeTeamID,
//                       const Color(0xFF2374AB)
//                   ), // Blue
//                 ],
//               ),
//
//               // Only show the Divider and Time if it's a standard view or paid view
//               const Divider(height: 30, indent: 20, endIndent: 20),
//
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.calendar_today,
//                     size: 16,
//                     color: Color(0xFF143109),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     "Start Time: $formattedTime",
//                     style: const TextStyle(
//                       color: Color(0xFF143109),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//
//               // Value Bet Indicator for Non-Paid users
//               if (!isPaid) ...[
//                 const SizedBox(height: 10),
//                 _blurredValueBet(),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTeamDisplay(String name, String abbr, Color circleColor) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         CircleAvatar(
//           radius: 35, // Original Radius
//           backgroundColor: circleColor,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Image.asset(
//               'assets/logos/$abbr.png',
//               fit: BoxFit.contain,
//               errorBuilder: (context, error, stackTrace) =>
//                   const Icon(Icons.sports_baseball, color: Colors.white, size: 30),
//             ),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           abbr,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
//
//   Widget _blurredValueBet() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade300,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: const Text(
//         "Premium Content Hidden",
//         style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black54),
//       ),
//     );
//   }
// }