import 'package:app/main.dart';
import 'package:app/features/historical_accuracy/presentation/screens/historical_accuracy_screen.dart';
import 'package:app/features/subscription/presentation/screens/my_subscription_screen.dart';
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

    // Verify that the default page is DailyPredictionsPage.
    expect(find.byType(DailyPredictionsPage), findsOneWidget);
    expect(find.byType(SettingsPage), findsNothing);

    // Tap the 'Settings & Predictions' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    // Verify that SettingsPage is displayed.
    expect(find.byType(DailyPredictionsPage), findsNothing);
    expect(find.byType(SettingsPage), findsOneWidget);


    // Go back to Subscription
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    // Verify that DailyPredictionsPage is displayed again.
    expect(find.byType(DailyPredictionsPage), findsOneWidget);
    expect(find.byType(SettingsPage), findsNothing);
  });
}
