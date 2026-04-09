import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import your main app file
import 'package:app/main.dart';

// Import your screen widgets directly so the test can find them by type
import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart'; // Adjust path if needed
// import 'package:app/features/profile/presentation/screens/profile_screen.dart'; // Uncomment when created
// import 'package:app/features/settings/presentation/screens/settings_screen.dart'; // Adjust path if needed

void main() {
  group('Main NavigationShell Tests', () {

    testWidgets('App launches directly into Daily Predictions', (WidgetTester tester) async {
      // 1. Build our app and trigger a frame.
      await tester.pumpWidget(const ProviderScope(child: MyApp()));

      // 2. Wait for any initial animations or FutureProviders to settle
      await tester.pumpAndSettle();

      // 3. Verify the default page is DailyPredictionsPage
      expect(find.byType(DailyPredictionsPage), findsOneWidget);

      // Ensure other screens are NOT present
      // expect(find.byType(SettingsPage), findsNothing);
    });

    testWidgets('Can navigate back and forth between Predictions and Settings', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // --- NAVIGATE TO SETTINGS ---
      // Find the tab by its icon. (Change Icons.person to whatever your settings/profile tab actually uses)
      final settingsTab = find.byIcon(Icons.person);
      expect(settingsTab, findsOneWidget);

      await tester.tap(settingsTab);
      await tester.pumpAndSettle(); // Critical: Wait for the slide/fade transition to finish

      // Verify we arrived at the Settings page
      // expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(DailyPredictionsPage), findsNothing);

      // --- NAVIGATE BACK TO PREDICTIONS ---
      // Find the predictions tab. (Change Icons.home to your actual predictions tab icon)
      final predictionsTab = find.byIcon(Icons.home);
      expect(predictionsTab, findsOneWidget);

      await tester.tap(predictionsTab);
      await tester.pumpAndSettle();

      // Verify we are back on the Predictions page
      expect(find.byType(DailyPredictionsPage), findsOneWidget);
      // expect(find.byType(SettingsPage), findsNothing);
    });

    /* ========================================================================
    FUTURE TESTS: Uncomment and adjust these as you build out your screens.
    Ensure you import the specific screen classes at the top of this file.
    ========================================================================
    */

    /*
    testWidgets('Can navigate to Historical Accuracy Screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Assuming Historical Accuracy is a tab in the bottom nav
      final historyTab = find.byIcon(Icons.history);
      await tester.tap(historyTab);
      await tester.pumpAndSettle();

      expect(find.byType(HistoricalAccuracyScreen), findsOneWidget);
      expect(find.byType(DailyPredictionsPage), findsNothing);
    });
    */

    /*
    testWidgets('Can navigate to Subscription Screen from Profile', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // 1. Navigate to Profile/Settings Tab first
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // 2. Find the "Manage Subscription" button or list tile and tap it
      // Replace 'Manage Subscription' with the exact text on your button
      final subscriptionButton = find.text('Manage Subscription');
      await tester.ensureVisible(subscriptionButton); // Useful if it's inside a scrollable list
      await tester.tap(subscriptionButton);
      await tester.pumpAndSettle();

      // 3. Verify the Subscription screen pushed over the current view
      expect(find.byType(MySubscriptionScreen), findsOneWidget);

      // 4. Test the back button (the default AppBar back button)
      final backButton = find.byType(BackButton);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify we returned to the previous screen
      // expect(find.byType(ProfileScreen), findsOneWidget);
    });
    */

    /*
    testWidgets('Can navigate to Profile Screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      final profileTab = find.byIcon(Icons.account_circle);
      await tester.tap(profileTab);
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
    });
    */
  });
}