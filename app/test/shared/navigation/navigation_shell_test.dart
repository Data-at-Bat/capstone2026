import 'package:app/app/app.dart';
import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart';
import 'package:app/features/subscription/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:go_router/go_router.dart';

void main() {
  testWidgets('NavigationShell displays pages and navigates correctly', (
    WidgetTester tester,
  ) async {
    // Build app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the default page is DailyPredictionsPage.
    expect(find.byType(DailyPredictionsPage), findsOneWidget);
    expect(find.byType(SettingsPage), findsNothing);

    // Tap the 'Settings & Predictions' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    // Verify that SettingsPage is displayed.
    expect(find.byType(DailyPredictionsPage), findsNothing);
    expect(find.byType(SettingsPage), findsOneWidget);


    // Tap the 'Daily Predictions' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.list_alt));
    await tester.pumpAndSettle();

    // Verify that DailyPredictionsPage is displayed again.
    expect(find.byType(DailyPredictionsPage), findsOneWidget);
    expect(find.byType(SettingsPage), findsNothing);
  });
}
