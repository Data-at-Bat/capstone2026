import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:app/features/subscription/data/repositories/mock_subscription_repository.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return MockSubscriptionRepository();
});

final subscriptionStateProvider = StreamProvider<bool>((ref) {
  return ref.watch(subscriptionRepositoryProvider).subscriptionStatusChanges;
});

class SubscriptionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> purchaseSubscription() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(subscriptionRepositoryProvider).purchaseSubscription());
  }

  Future<void> restorePurchases() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(subscriptionRepositoryProvider).restorePurchases());
  }
}

final subscriptionControllerProvider = AsyncNotifierProvider<SubscriptionController, void>(SubscriptionController.new);
