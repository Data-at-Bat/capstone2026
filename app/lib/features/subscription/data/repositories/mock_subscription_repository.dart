import 'dart:async';

import 'package:app/features/subscription/domain/repositories/subscription_repository.dart';

class MockSubscriptionRepository implements SubscriptionRepository {
  final _controller = StreamController<bool>.broadcast();
  bool _isSubscribed = true;

  @override
  Stream<bool> get subscriptionStatusChanges async* {
    yield _isSubscribed;
    yield* _controller.stream;
  }

  @override
  bool get isSubscribed => _isSubscribed;

  @override
  Future<void> purchaseSubscription() async {
    _isSubscribed = true;
    _controller.add(true);
  }

  @override
  Future<void> restorePurchases() async {
    _isSubscribed = true;
    _controller.add(true);
  }
}
