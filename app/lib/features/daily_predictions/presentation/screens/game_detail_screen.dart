import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/game_matchup.dart';

class GameDetailScreen extends StatelessWidget {
  final GameMatchup gameData;
  final String userId;

  const GameDetailScreen({
    super.key,
    required this.gameData,
    required this.userId,
  });

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
    return idMap[teamId] ?? teamId;
  }

  // Helper method to map Team Abbreviations to their official hex colors
  Color _getTeamColor(String teamAbbr) {
    switch (teamAbbr.toUpperCase()) {
      case 'BAL': return const Color(0xFFDF4601);
      case 'BOS': return const Color(0xFFBD3039);
      case 'NYY': return const Color(0xFF003087);
      case 'TB':  return const Color(0xFF092C5C);
      case 'TOR': return const Color(0xFF134A8E);
      case 'CWS': return const Color(0xFF27251F);
      case 'CLE': return const Color(0xFFE31937);
      case 'DET': return const Color(0xFF0C2340);
      case 'KC':  return const Color(0xFF004687);
      case 'MIN': return const Color(0xFF002B5C);
      case 'HOU': return const Color(0xFFEB6E1F);
      case 'LAA': return const Color(0xFFBA0021);
      case 'OAK': return const Color(0xFF003831);
      case 'SEA': return const Color(0xFF005C5C);
      case 'TEX': return const Color(0xFF003278);
      case 'ATL': return const Color(0xFFCE1141);
      case 'MIA': return const Color(0xFF00A3E0);
      case 'NYM': return const Color(0xFFFF5910);
      case 'PHI': return const Color(0xFFE81828);
      case 'WSH': return const Color(0xFFAB0003);
      case 'CHC': return const Color(0xFF0E3386);
      case 'CIN': return const Color(0xFFC6011F);
      case 'MIL': return const Color(0xFF12284B);
      case 'PIT': return const Color(0xFFFDB827);
      case 'STL': return const Color(0xFFC41E3A);
      case 'ARI': return const Color(0xFFA71930);
      case 'COL': return const Color(0xFF33006F);
      case 'LAD': return const Color(0xFF005A9C);
      case 'SD':  return const Color(0xFF2F241D);
      case 'SF':  return const Color(0xFFFD5A1E);
      default: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the exact same formatting as DailyPredictionsPage
    final String formattedTime = DateFormat.jm().format(gameData.gameTime);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Game Time: $formattedTime',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: _buildContent(context, gameData),
    );
  }

  Widget _buildContent(BuildContext context, GameMatchup game) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMatchupHeader(game),
          const SizedBox(height: 32),
          _buildPredictedWinnerBanner(game),
          const SizedBox(height: 24),
          _buildStatBadges(game),
          const SizedBox(height: 32),
          _buildPredictiveFactorsList(game.predictiveFactors),

          // Only show the Value Bet card if it's an underdog pick
          if (game.odds > 0) ...[
            const SizedBox(height: 32),
            _buildValueBetCard(game),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildMatchupHeader(GameMatchup game) {
    return Row(
      children: [
        Expanded(child: _buildTeamCard(game.awayTeamId, game.awayTeamName, isAway: true)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'AT',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.grey[400]),
          ),
        ),
        Expanded(child: _buildTeamCard(game.homeTeamId, game.homeTeamName, isAway: false)),
      ],
    );
  }

  Widget _buildTeamCard(String teamId, String? teamName, {required bool isAway}) {
    String teamAbbr = _getAbbreviation(teamId);
    Color teamColor = _getTeamColor(teamAbbr);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border(
          bottom: BorderSide(color: teamColor, width: 4),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [teamColor.withValues(alpha: 0.1), teamColor.withValues(alpha: 0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                'assets/logos/$teamAbbr.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(teamAbbr, style: TextStyle(fontWeight: FontWeight.bold, color: teamColor, fontSize: 18)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            teamAbbr,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          if (teamName != null)
            Text(
              teamName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildPredictedWinnerBanner(GameMatchup game) {
    String winnerAbbr = "UNKNOWN";
    if (game.predictedWinner == game.homeTeamName) {
      winnerAbbr = _getAbbreviation(game.homeTeamId);
    } else if (game.predictedWinner == game.awayTeamName) {
      winnerAbbr = _getAbbreviation(game.awayTeamId);
    }

    // FIX: Removed 'game.predictedWinner != null' because it's non-nullable.
    Color winnerColor = _getTeamColor(winnerAbbr);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: winnerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: winnerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, color: winnerColor),
          const SizedBox(width: 8),
          Text(
            'Model Pick: ',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          Text(
            game.predictedWinner, // FIX: Removed '?? "TBD"' dead code
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: winnerColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadges(GameMatchup game) {
    // FIX: Removed '!= null' checks. Directly format the doubles.
    String formattedSpread = game.spread > 0 ? "+${game.spread}" : game.spread.toString();
    String formattedOdds = game.odds > 0 ? "+${game.odds}" : game.odds.toString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // FIX: Removed the '?' from confidence because it's non-nullable
        _buildSingleBadge("Confidence", "${game.confidence.toStringAsFixed(1)}%", Icons.query_stats, Colors.blue),
        const SizedBox(width: 12),
        _buildSingleBadge("Spread", formattedSpread, Icons.compare_arrows, Colors.orange),
        const SizedBox(width: 12),
        _buildSingleBadge("Odds", formattedOdds, Icons.attach_money, Colors.green),
      ],
    );
  }

  Widget _buildSingleBadge(String title, String value, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  String _formatStatKey(String key) {
    return key.split('_').map((word) {
      if (word.isEmpty) return '';
      if (word.toLowerCase() == 'ops') return 'OPS';
      if (word.toLowerCase() == 'era') return 'ERA';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildPredictiveFactorsList(Map<String, dynamic> factors) {
    // FIX: Removed 'factors == null' check since factors is non-nullable.
    if (factors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights, color: Colors.black54, size: 20),
              SizedBox(width: 8),
              Text("Key Predictive Factors", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(height: 1),
          ),

          ...factors.entries.map((entry) {
            String formattedKey = _formatStatKey(entry.key);
            String formattedValue = entry.value is double
                ? (entry.value as double).toStringAsFixed(3)
                : entry.value.toString();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Icon(Icons.check_circle, color: Color(0xFF2374AB), size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey[800]),
                        children: [
                          TextSpan(text: '$formattedKey: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: formattedValue),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // FIX: Removed all blur logic, lock icons, and dummy wrappers. Unlocked for everyone!
  Widget _buildValueBetCard(GameMatchup game) {
    String oddsStr = game.odds > 0 ? "+${game.odds}" : game.odds.toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade400, width: 1.5),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_fire_department, color: Colors.green),
              SizedBox(width: 8),
              Text('VALUE BET EDGE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.green, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Model detects massive value on the current line.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.green[800])),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Text('Play: $oddsStr', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          ),
        ],
      ),
    );
  }
}