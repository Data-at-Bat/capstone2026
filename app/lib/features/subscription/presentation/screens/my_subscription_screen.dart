import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/subscription/presentation/providers/subscription_provider.dart';

class MySubscriptionPage extends ConsumerWidget {
  const MySubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionStateProvider);
    final subscriptionController = ref.watch(subscriptionControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subscription'),
      ),
      body: Center(
        child: subscriptionState.when(
          data: (isSubscribed) {
            if (isSubscribed) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'You are subscribed!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Enjoy full access to MLB predictions.'),
                  SizedBox(height: 32),
                  // Maybe show some subscription details or "Manage Subscription" button
                ],
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, color: Colors.orange, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Unlock Full Access',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Subscribe to see all daily predictions and historical accuracy data.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (subscriptionController.isLoading)
                      const CircularProgressIndicator()
                    else
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              ref.read(subscriptionControllerProvider.notifier).purchaseSubscription();
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('Subscribe Now'),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              ref.read(subscriptionControllerProvider.notifier).restorePurchases();
                            },
                            child: const Text('Restore Purchases'),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            }
          },
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        ),
      ),
    );
  }
}
