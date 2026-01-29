import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart';
import 'package:app/features/historical_accuracy/presentation/screens/historical_accuracy_screen.dart';
import 'package:app/features/subscription/presentation/screens/my_subscription_screen.dart';
import 'package:app/shared/navigation/navigation_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NavigationShell displays pages and navigates correctly', (
    WidgetTester tester,
  ) async {
    // Build app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: NavigationShell()));

    // Verify that the default page is DailyPredictionsPage.
    expect(find.byType(DailyPredictionsPage), findsOneWidget);
    expect(find.byType(MySubscriptionPage), findsNothing);
    expect(find.byType(HistoricalAccuracyPage), findsNothing);

    // Tap the 'My Subscription' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    // Verify that MySubscriptionPage is displayed.
    expect(find.byType(DailyPredictionsPage), findsNothing);
    expect(find.byType(MySubscriptionPage), findsOneWidget);
    expect(find.byType(HistoricalAccuracyPage), findsNothing);

    // Tap the 'Historical Accuracy' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();

    // Verify that HistoricalAccuracyPage is displayed.
    expect(find.byType(DailyPredictionsPage), findsNothing);
    expect(find.byType(MySubscriptionPage), findsNothing);
    expect(find.byType(HistoricalAccuracyPage), findsOneWidget);

    // Tap the 'Daily Predictions' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.list_alt));
    await tester.pumpAndSettle();

    // Verify that DailyPredictionsPage is displayed again.
    expect(find.byType(DailyPredictionsPage), findsOneWidget);
    expect(find.byType(MySubscriptionPage), findsNothing);
    expect(find.byType(HistoricalAccuracyPage), findsNothing);
  });
}
