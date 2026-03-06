import 'package:app/shared/router/router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AppRouter', () {
    test('contains all the required routes', () {
      final route = AppRouter.router.configuration.routes.first;
      expect(route, isA<StatefulShellRoute>());
      final shellRoute = route as StatefulShellRoute;
      final paths = shellRoute.branches
          .expand((branch) => branch.routes)
          .whereType<GoRoute>()
          .map((route) => route.path)
          .toList();

      expect(paths, contains('/daily-predictions'));
      expect(paths, contains('/my-subscription'));
    });
  });
}
