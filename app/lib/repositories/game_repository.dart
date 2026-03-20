import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game_matchup.dart'; 

class GameRepository {

  final bool _useMockData = false; // Set to true to use mock data instead of making actual API calls
  final String baseUrl = 'http://localhost:8080'; 
  // Fetches ALL games for the day, including deep stats and predictions
     // In the future there wll need to be userId and isPaidMember parameters to determine what data to return (blurred/unblurred)

    Future<List<GameMatchup>> fetchDailyGames({
          DateTime? startDate,
          DateTime? endDate,
          List<String>? teams,
        }) async {
          try {
            // Simulate network delay
            await Future.delayed(const Duration(seconds: 1));
            if (_useMockData) {
              // Return mock data for testing
              return [
                GameMatchup(
                  gameId: '101',
                  gameTime: DateTime.now().add(const Duration(hours: 2)),
                  homeTeamName: 'Cardinals',
                  awayTeamName: 'Cubs',
                  homeTeamId: 'STL',
                  awayTeamId: 'CHC',
                  predictedWinner: 'STL',
                  confidence: 80.0,
                  odds: 150.0,
                  spread: -2,
                  predictiveFactors: ['Strong offense', 'Weak opponent pitching']
                ),
                GameMatchup(
                  gameId: '102',
                  gameTime: DateTime.now().add(const Duration(hours: 5)),
                  homeTeamName: 'Dodgers',
                  awayTeamName: 'Giants',
                  homeTeamId: 'LAD',
                  awayTeamId: 'SF',
                  predictedWinner: 'LAD',
                  confidence: 72.0,
                  odds: -110.0,
                  spread: -1.5,
                  predictiveFactors: ['Strong offense', 'Weak opponent pitching'],
                ),
              ];
            }
            // Set up default dates as specified in your table
            final now = DateTime.now();
            final defaultStart = DateTime(now.year, now.month, now.day);
            final defaultEnd = defaultStart.add(const Duration(days: 7));

            // Construct the query parameters
            final Map<String, String> queryParameters = {
              'StartDate': (startDate ?? defaultStart).toIso8601String(),
              'EndDate': (endDate ?? defaultEnd).toIso8601String(),
            };

            if (teams != null && teams.isNotEmpty) {
              // Typically arrays in query params are comma-separated or repeated
              queryParameters['Teams'] = teams.join(','); 
            }

            // Attach query parameters directly to the URL
            final uri = Uri.parse('$baseUrl/games');
            
            // Use the standard http.get now that the body is removed
            final response = await http.get(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            );

            if (response.statusCode == 200) {
              final List<dynamic> gamesJson = json.decode(response.body);

              return gamesJson.map((json) => GameMatchup.fromJson(json)).toList();
            } else {
              throw Exception('Failed to load games: Status ${response.statusCode}');
            }
          } catch (e) {
            throw Exception('Error fetching games: $e');
          }
        }
      }