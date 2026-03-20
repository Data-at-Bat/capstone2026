import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../models/game_matchup.dart';

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

  // Helper method to map Team IDs to their official hex colors
// Helper method to map Team IDs to their official hex colors
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
    // String formattedDate = "${gameData.gameTime.month}/${gameData.gameTime.day}/${gameData.gameTime.year}";

    return Scaffold(
      backgroundColor: Colors.grey[50], // Very light clean background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Game Time: ${gameData.gameTime.hour}:${gameData.gameTime.minute}',
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
          // Dynamic Color Matchup Header
          _buildMatchupHeader(game),
          const SizedBox(height: 32),

          // Predicted Winner Highlight
          _buildPredictedWinnerBanner(game),
          const SizedBox(height: 24),

          // Stat Badges Row
          _buildStatBadges(game),
          const SizedBox(height: 32),

          // Clean Predictive Factors List
          _buildPredictiveFactorsList(game.predictiveFactors),
          const SizedBox(height: 32),

          // Impenetrable Premium Value Bet
          _buildValueBetIndicator(isPaidMember, game),
          const SizedBox(height: 40), // Bottom padding
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
    Color teamColor = _getTeamColor(teamId);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border(
          bottom: BorderSide(color: teamColor, width: 4), // Sleek color accent at the bottom
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
                'assets/logos/$teamId.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(teamId, style: TextStyle(fontWeight: FontWeight.bold, color: teamColor, fontSize: 18)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            teamId,
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
    Color winnerColor = game.predictedWinner != null ? _getTeamColor(game.predictedWinner!) : Colors.grey;

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
            game.predictedWinner ?? "TBD",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: winnerColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadges(GameMatchup game) {
    String formattedSpread = "N/A";
    if (game.spread != null) {
      formattedSpread = game.spread! > 0 ? "+${game.spread}" : game.spread.toString();
    }

    String formattedOdds = "N/A";
    if (game.odds != null) {
      formattedOdds = game.odds! > 0 ? "+${game.odds}" : game.odds.toString();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSingleBadge("Confidence", "${game.confidence?.toStringAsFixed(1) ?? "--"}%", Icons.query_stats, Colors.blue),
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

  Widget _buildPredictiveFactorsList(List<String>? factors) {
    if (factors == null || factors.isEmpty) {
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
          ...factors.map((factor) => Padding(
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
                  child: Text(factor, style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey[800])),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildValueBetIndicator(bool isPaidMember, GameMatchup game) {
    // The actual content card
    Widget buildPremiumContent(bool isDummy) {
      String oddsStr = "N/A";
      if (!isDummy && game.odds != null) {
        oddsStr = game.odds! > 0 ? "+${game.odds}" : game.odds.toString();
      } else if (isDummy) {
        oddsStr = "+150"; // Fake data for the blur background
      }

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

    if (isPaidMember) {
      return buildPremiumContent(false);
    } else {
      // Impenetrable Blur: Render fake content, heavily blur it, and overlay a white tint
      return Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Container(
                foregroundDecoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5), // Whitewash overlay
                ),
                child: buildPremiumContent(true), // Injecting FAKE data so real odds never hit the screen
              ),
            ),
          ),

          // Lock Button
          ElevatedButton.icon(
            icon: const Icon(Icons.lock, size: 20),
            label: const Text('Unlock Value Bets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 4,
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