import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/profile/presentation/providers/favorites_provider.dart';

class FavoritesSelectionScreen extends ConsumerStatefulWidget {
  const FavoritesSelectionScreen({super.key});

  @override
  ConsumerState<FavoritesSelectionScreen> createState() => _FavoritesSelectionScreenState();
}

class _FavoritesSelectionScreenState extends ConsumerState<FavoritesSelectionScreen> {
  late Set<String> _selectedMlbIds;
  bool _isLoading = false;

  final List<Map<String, String>> _allTeams = const [
    {'id': '109', 'abbr': 'ARI', 'name': 'Arizona Diamondbacks'},
    {'id': '144', 'abbr': 'ATL', 'name': 'Atlanta Braves'},
    {'id': '110', 'abbr': 'BAL', 'name': 'Baltimore Orioles'},
    {'id': '111', 'abbr': 'BOS', 'name': 'Boston Red Sox'},
    {'id': '112', 'abbr': 'CHC', 'name': 'Chicago Cubs'},
    {'id': '145', 'abbr': 'CWS', 'name': 'Chicago White Sox'},
    {'id': '113', 'abbr': 'CIN', 'name': 'Cincinnati Reds'},
    {'id': '114', 'abbr': 'CLE', 'name': 'Cleveland Guardians'},
    {'id': '115', 'abbr': 'COL', 'name': 'Colorado Rockies'},
    {'id': '116', 'abbr': 'DET', 'name': 'Detroit Tigers'},
    {'id': '117', 'abbr': 'HOU', 'name': 'Houston Astros'},
    {'id': '118', 'abbr': 'KC', 'name': 'Kansas City Royals'},
    {'id': '108', 'abbr': 'LAA', 'name': 'Los Angeles Angels'},
    {'id': '119', 'abbr': 'LAD', 'name': 'Los Angeles Dodgers'},
    {'id': '146', 'abbr': 'MIA', 'name': 'Miami Marlins'},
    {'id': '158', 'abbr': 'MIL', 'name': 'Milwaukee Brewers'},
    {'id': '142', 'abbr': 'MIN', 'name': 'Minnesota Twins'},
    {'id': '121', 'abbr': 'NYM', 'name': 'New York Mets'},
    {'id': '147', 'abbr': 'NYY', 'name': 'New York Yankees'},
    {'id': '133', 'abbr': 'OAK', 'name': 'Oakland Athletics'},
    {'id': '143', 'abbr': 'PHI', 'name': 'Philadelphia Phillies'},
    {'id': '134', 'abbr': 'PIT', 'name': 'Pittsburgh Pirates'},
    {'id': '135', 'abbr': 'SD', 'name': 'San Diego Padres'},
    {'id': '137', 'abbr': 'SF', 'name': 'San Francisco Giants'},
    {'id': '136', 'abbr': 'SEA', 'name': 'Seattle Mariners'},
    {'id': '138', 'abbr': 'STL', 'name': 'St. Louis Cardinals'},
    {'id': '139', 'abbr': 'TB', 'name': 'Tampa Bay Rays'},
    {'id': '140', 'abbr': 'TEX', 'name': 'Texas Rangers'},
    {'id': '141', 'abbr': 'TOR', 'name': 'Toronto Blue Jays'},
    {'id': '120', 'abbr': 'WSH', 'name': 'Washington Nationals'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with whatever is currently in the provider
    _selectedMlbIds = ref.read(favoritesProvider).maybeWhen(
      data: (data) => data.toSet(),
      orElse: () => <String>{},
    );
  }

  Future<void> _saveFavorites() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).currentUser;
      final token = await user?.getIdToken();
      print("===== MY FIREBASE TOKEN =====");
      print(token);
      print("=============================");

      final List<String> uuids = _selectedMlbIds
          .map((id) => mlbIdToUuid[id])
          .whereType<String>()
          .toList();

      final response = await http.post(
        Uri.parse('$API_BASE_URL/favorites/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({"teamIds": uuids}),
      );

      if (response.statusCode == 200) {
        // Trigger a global refresh of the favorites data
        ref.invalidate(favoritesProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Favorites updated!'), backgroundColor: Colors.green));
          context.pop(); // Using GoRouter
        }
      } else {
        throw Exception("Server Error ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleTeam(String teamId) {
    setState(() {
      if (_selectedMlbIds.contains(teamId)) {
        _selectedMlbIds.remove(teamId);
      } else {
        _selectedMlbIds.add(teamId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider just so the screen shows loading if it hasn't resolved yet
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text('Favorite Teams', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xFF462255),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: favoritesAsync.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF462255)))
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _allTeams.length,
        itemBuilder: (context, index) {
          final team = _allTeams[index];
          final isSelected = _selectedMlbIds.contains(team['id']);
          return _buildTeamCell(team, isSelected);
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isLoading || favoritesAsync.isLoading ? null : _saveFavorites,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF462255),
              disabledBackgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save Favorites', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCell(Map<String, String> team, bool isSelected) {
    final String abbr = team['abbr']!;
    return GestureDetector(
      onTap: () => _toggleTeam(team['id']!),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF462255) : Colors.transparent, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logos/$abbr.png', height: 40, errorBuilder: (_, __, ___) => Text(abbr)),
                const SizedBox(height: 8),
                Text(abbr, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF462255) : Colors.black)),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Color(0xFF462255), shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}