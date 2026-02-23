abstract class SubscriptionRepository {
  Stream<bool> get subscriptionStatusChanges;
  Future<void> purchaseSubscription();
  Future<void> restorePurchases();
  bool get isSubscribed;
}
