import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game_matchup.dart';

class GameRepository {

  final bool _useMockData = true; // Set to true to use mock data instead of making actual API calls
  final String baseUrl = 'http://localhost:8080';

  // Fetches ALL games for the day, including deep stats and predictions
  // In the future there wll need to be userId and isPaidMember parameters to determine what data to return (blurred/unblurred)
  Future<List<GameMatchup>> fetchDailyGames({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? teams,
  }) async {
    try {
      if (_useMockData) {
        // Simulate network delay
        await Future.delayed(const Duration(seconds: 1));
        // Return mock data for testing
        return [
          GameMatchup(
            gameId: '101',
            gameTime: DateTime.now().add(const Duration(hours: 2)),
            homeTeamName: 'St. Louis Cardinals',
            awayTeamName: 'Chicago Cubs',
            homeTeamId: '138', // Using numeric IDs to match MLB Stats API
            awayTeamId: '112',
            predictedWinner: 'St. Louis Cardinals',
            confidence: 80.0,
            odds: 150.0,
            spread: -2.0,
            predictiveFactors: {
              'home_ops': 0.768,
              'away_ops': 0.636,
              'home_pitching_era': 3.53,
              'away_pitching_era': 4.71
            },
          ),
          GameMatchup(
            gameId: '102',
            gameTime: DateTime.now().add(const Duration(hours: 5)),
            homeTeamName: 'Los Angeles Dodgers',
            awayTeamName: 'San Francisco Giants',
            homeTeamId: '119',
            awayTeamId: '137',
            predictedWinner: 'Los Angeles Dodgers',
            confidence: 72.0,
            odds: -110.0,
            spread: -1.5,
            predictiveFactors: {
              'home_ops': 0.812,
              'away_ops': 0.690,
              'home_pitching_era': 2.85,
              'away_pitching_era': 4.39
            },
          ),
        ];
      }

      // Set up default dates as specified
      final now = DateTime.now();
      final defaultStart = DateTime(now.year, now.month, now.day);
      final defaultEnd = defaultStart.add(const Duration(days: 7));

      // Construct the query parameters using exact camelCase matching the Spring Boot GameController
      final Map<String, String> queryParameters = {
        'startDate': (startDate ?? defaultStart).toIso8601String(),
        'endDate': (endDate ?? defaultEnd).toIso8601String(),
      };

      if (teams != null && teams.isNotEmpty) {
        queryParameters['teamIds'] = teams.join(',');
      }

      // Attach query parameters cleanly to the URI
      final queryString = Uri(queryParameters: queryParameters).query;
      final uri = Uri.parse('$baseUrl/games?$queryString');


      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);

        // SAFE PARSING: Prevent _JsonMap type errors
        if (decodedData is List) {
          // Standard Spring Boot List Return
          return decodedData.map((json) => GameMatchup.fromJson(json)).toList();

        } else if (decodedData is Map<String, dynamic>) {
          // Wrapped JSON Object (Matches the Master Document structure)
          if (decodedData.containsKey('Games')) {
            final List<dynamic> gamesList = decodedData['Games'];
            return gamesList.map((json) => GameMatchup.fromJson(json)).toList();
          } else {
            throw Exception('Unexpected JSON Map: Missing "Games" key.');
          }

        } else {
          throw Exception('Unexpected JSON Format: Neither a List nor a Map.');
        }
      } else {
        // Include the response body in the exception to surface Spring Boot error messages
        throw Exception('Failed to load games: Status ${response.statusCode}. Details: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}