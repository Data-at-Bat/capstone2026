import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart';
import 'package:app/features/subscription/presentation/screens/my_subscription_screen.dart';
import 'package:app/features/historical_accuracy/presentation/screens/historical_accuracy_screen.dart';
import 'package:app/shared/navigation/navigation_shell.dart';

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialLocation: '/daily-predictions',
    refreshListenable: notifier,
    redirect: (context, state) {
      final subState = ref.read(subscriptionStateProvider);
      final isSubscribed = subState.value == true;

      if (!isSubscribed) {
        if (state.uri.path == '/daily-predictions') {
          return '/my-subscription';
        }
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/daily-predictions',
                builder: (context, state) => const DailyPredictionsPage(),
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
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<bool>>(
      subscriptionStateProvider,
      (_, _) => notifyListeners(),
    );
  }
}
