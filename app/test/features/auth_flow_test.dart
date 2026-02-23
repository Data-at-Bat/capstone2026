import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/main.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart';
import 'package:app/features/subscription/presentation/screens/my_subscription_screen.dart';
import 'package:app/features/daily_predictions/presentation/screens/daily_predictions_screen.dart';

void main() {
  testWidgets('Full Auth and Subscription Flow', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // 1. Verify we start at LoginScreen (unauthenticated)
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);

    // 2. Sign In
    await tester.tap(find.text('Continue with Google'));
    await tester.pump(); // Trigger action
    
    // The mock repository has a delay of 500ms. Pump for longer.
    await tester.pump(const Duration(milliseconds: 1000)); 
    await tester.pumpAndSettle(); // Allow router to react

    // 3. Verify we are redirected to MySubscriptionPage (Authenticated but Unsubscribed)
    expect(find.byType(MySubscriptionPage), findsOneWidget, reason: 'Should be on Subscription Page');
    expect(find.text('Unlock Full Access'), findsOneWidget);

    // 4. Purchase Subscription
    await tester.tap(find.text('Subscribe Now'));
    await tester.pump();
    
    // Mock repo delay 1000ms
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // 5. Verify we are still on MySubscriptionPage but state changed
    expect(find.text('You are subscribed!'), findsOneWidget);

    // 6. Navigate to Daily Predictions (Home) via Bottom Navigation
    await tester.tap(find.byIcon(Icons.list_alt));
    await tester.pumpAndSettle();

    // 7. Verify we are on DailyPredictionsPage
    expect(find.byType(DailyPredictionsPage), findsOneWidget);
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Daily Predictions')), findsOneWidget);
  });
}
