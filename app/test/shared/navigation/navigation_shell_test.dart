import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:app/main.dart';
import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart';
import 'package:app/features/subscription/presentation/screens/settings_screen.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';

// Create a dummy user so GoRouter allows us into the app
class MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Main NavigationShell Tests', () {
    late MockUser mockUser;

    setUp(() {
      mockUser = MockUser();
    });

    testWidgets('App launches directly into Daily Predictions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Fake the auth state to bypass the login redirect
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(find.byType(DailyPredictionsPage), findsOneWidget);
    });

    testWidgets('Can navigate back and forth', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // --- NAVIGATE TO SETTINGS ---
      // Fixed: navigation_shell.dart uses Icons.person
      final settingsTab = find.byIcon(Icons.person);
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      expect(find.byType(DailyPredictionsPage), findsNothing);
      expect(find.byType(SettingsPage), findsOneWidget);

      // --- NAVIGATE BACK TO PREDICTIONS ---
      // Fixed: navigation_shell.dart uses Icons.list_alt
      final predictionsTab = find.byIcon(Icons.list_alt);
      await tester.tap(predictionsTab);
      await tester.pumpAndSettle();

      expect(find.byType(DailyPredictionsPage), findsOneWidget);
    });
  });
}