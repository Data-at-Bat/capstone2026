import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart';
import 'package:app/features/subscription/presentation/screens/settings_screen.dart';
import 'package:app/shared/navigation/navigation_shell.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart';
import 'package:app/features/auth/presentation/screens/signup_screen.dart';
import 'package:app/features/profile/presentation/screens/profile_screen.dart';
import 'package:app/features/auth/presentation/screens/change_password_screen.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Watch the auth state so the router rebuilds when login/logout happens
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialLocation: '/daily-predictions',

    redirect: (context, state) {
      // If authState is still loading, don't redirect yet
      if (authState.isLoading) return null;

      final isAuth = authState.value != null;
      final isGoingToLogin = state.uri.path == '/login';
      final isGoingToSignup = state.uri.path == '/signup';

      // If they are NOT logged in and trying to access the main app, kick to login
      if (!isAuth && !isGoingToLogin && !isGoingToSignup) {
        return '/login';
      }

      // If they ARE logged in but trying to view the login screen, push to home
      if (isAuth && (isGoingToLogin || isGoingToSignup)) {
        return '/daily-predictions';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
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
                path: '/settings', // Changed from /my-subscription
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});