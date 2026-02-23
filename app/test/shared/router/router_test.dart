import 'package:app/shared/router/router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('AppRouter', () {
    test('contains all the required routes', () {
      final container = ProviderContainer();
      final router = container.read(routerProvider);
      
      final route = router.configuration.routes.firstWhere((r) => r is StatefulShellRoute);
      expect(route, isA<StatefulShellRoute>());
      
      final shellRoute = route as StatefulShellRoute;
      final paths = shellRoute.branches
          .expand((branch) => branch.routes)
          .whereType<GoRoute>()
          .map((route) => route.path)
          .toList();

      expect(paths, contains('/daily-predictions'));
      expect(paths, contains('/my-subscription'));
      expect(paths, contains('/historical-accuracy'));
      
      // Also verify auth routes
      final loginRoute = router.configuration.routes.any((r) => r is GoRoute && r.path == '/login');
      
      expect(loginRoute, isTrue);
    });
  });
}
