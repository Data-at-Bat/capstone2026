import 'dart:async';
import 'package:app/features/subscription/domain/repositories/subscription_repository.dart';

class MockSubscriptionRepository implements SubscriptionRepository {
  final _controller = StreamController<bool>.broadcast();
  bool _isSubscribed = true;

  MockSubscriptionRepository() {
    // Default to true for now.
  }

  @override
  Stream<bool> get subscriptionStatusChanges async* {
    yield _isSubscribed;
    yield* _controller.stream;
  }

  @override
  bool get isSubscribed => _isSubscribed;

  @override
  Future<void> purchaseSubscription() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _isSubscribed = true;
    _controller.add(true);
  }

  @override
  Future<void> restorePurchases() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    // Simulate restore finding a sub
    _isSubscribed = true;
    _controller.add(true);
  }
}
