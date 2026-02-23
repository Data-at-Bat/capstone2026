import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/daily_predictions/data/repositories/prediction_repository.dart';
import 'package:app/models/game_matchup.dart';

final predictionRepositoryProvider = Provider<PredictionRepository>((ref) {
  return PredictionRepository();
});

final dailyPredictionsProvider = FutureProvider<List<GameMatchup>>((ref) async {
  final repository = ref.watch(predictionRepositoryProvider);
  return repository.fetchDailyGames();
});
