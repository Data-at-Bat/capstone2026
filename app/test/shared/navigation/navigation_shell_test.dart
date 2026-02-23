import 'package:app/main.dart';
import 'package:app/features/historical_accuracy/presentation/screens/historical_accuracy_screen.dart';
import 'package:app/features/subscription/presentation/screens/my_subscription_screen.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('NavigationShell displays pages and navigates correctly', (
    WidgetTester tester,
  ) async {
    // Build app and trigger a frame.
    // Wrap with ProviderScope because MyApp uses Riverpod
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // NOTE: Because of AuthGate logic, we might start at LoginScreen.

    // Check if we are on LoginScreen and bypass if needed,
    // or just adjust expectations to current reality.

    if (find.byType(LoginScreen).evaluate().isNotEmpty) {
      // Perform mock login to get to the shell
      await tester.tap(find.text('Continue with Google'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();
    }

    // Now we should be on MySubscriptionPage (if not subscribed)
    // or DailyPredictionsPage (if subscribed).
    // The mock defaults to NOT subscribed, so we'll be on MySubscriptionPage.

    expect(find.byType(MySubscriptionPage), findsOneWidget);

    // Tap the 'Daily Predictions' icon.
    // It should redirect back to MySubscriptionPage if not subscribed.
    await tester.tap(find.byIcon(Icons.list_alt));
    await tester.pumpAndSettle();
    expect(find.byType(MySubscriptionPage), findsOneWidget);

    // Tap the 'Historical Accuracy' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();
    expect(find.byType(HistoricalAccuracyPage), findsOneWidget);

    // Go back to Subscription
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();
    expect(find.byType(MySubscriptionPage), findsOneWidget);
  });
}
