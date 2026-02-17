import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart';
import 'package:app/features/subscription/presentation/screens/my_subscription_screen.dart';
import 'package:app/features/historical_accuracy/presentation/screens/historical_accuracy_screen.dart';
import 'package:app/shared/navigation/navigation_shell.dart';
import 'package:app/repositories/game_repository.dart';


class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();
  static final GameRepository _gameRepository = GameRepository();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/daily-predictions',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: '/daily-predictions',
                builder: (context, state) => DailyPredictionsPage(
                  repository: _gameRepository,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-subscription',
                builder: (context, state) => const MySubscriptionPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/historical-accuracy',
                builder: (context, state) => const HistoricalAccuracyPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
