import 'package:app/shared/router/router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';

class MockUser extends Mock implements User {}

void main() {
  group('AppRouter', () {
    test('contains all the required routes', () {
      final mockUser = MockUser();

      final container = ProviderContainer(
        overrides: [
          // Override auth state so GoRouter initializes safely
          authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
        ],
      );

      final router = container.read(routerProvider);
      final routes = router.configuration.routes;

      List<String> extractPaths(List<RouteBase> routes) {
        List<String> paths = [];
        for (final route in routes) {
          if (route is GoRoute) {
            paths.add(route.path);
            paths.addAll(extractPaths(route.routes));
          } else if (route is StatefulShellRoute) {
            for (final branch in route.branches) {
              paths.addAll(extractPaths(branch.routes));
            }
          } else if (route is ShellRoute) {
            paths.addAll(extractPaths(route.routes));
          }
        }
        return paths;
      }

      final allPaths = extractPaths(routes);

      // Assert against the exact routes in router.dart
      expect(allPaths, contains('/daily-predictions'));
      expect(allPaths, contains('/settings'));
      expect(allPaths, contains('/login'));
      expect(allPaths, contains('/signup'));
      expect(allPaths, contains('/profile'));
      expect(allPaths, contains('/change-password'));
    });
  });
}