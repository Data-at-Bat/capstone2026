import 'dart:async';

import 'package:app/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:app/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestSubscriptionRepository implements SubscriptionRepository {
  TestSubscriptionRepository({
    bool initialValue = false,
    this.failPurchase = false,
    this.failRestore = false,
  }) : _isSubscribed = initialValue;

  final bool failPurchase;
  final bool failRestore;
  final _controller = StreamController<bool>.broadcast();
  bool _isSubscribed;

  @override
  Stream<bool> get subscriptionStatusChanges async* {
    yield _isSubscribed;
    yield* _controller.stream;
  }

  @override
  bool get isSubscribed => _isSubscribed;

  void emitSubscription(bool value) {
    _isSubscribed = value;
    _controller.add(value);
  }

  @override
  Future<void> purchaseSubscription() async {
    if (failPurchase) {
      throw Exception('purchase failed');
    }
    emitSubscription(true);
  }

  @override
  Future<void> restorePurchases() async {
    if (failRestore) {
      throw Exception('restore failed');
    }
    emitSubscription(true);
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  test('subscriptionStateProvider emits initial and updated values', () async {
    final repository = TestSubscriptionRepository(initialValue: false);
    addTearDown(repository.dispose);

    final container = ProviderContainer(
      overrides: [subscriptionRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final values = <AsyncValue<bool>>[];
    final subscription = container.listen<AsyncValue<bool>>(
      subscriptionStateProvider,
      (previous, next) => values.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    repository.emitSubscription(true);
    await Future<void>.delayed(Duration.zero);

    expect(values.last.value, isTrue);
  });

  test('purchaseSubscription transitions to a completed state', () async {
    final repository = TestSubscriptionRepository(initialValue: false);
    addTearDown(repository.dispose);

    final container = ProviderContainer(
      overrides: [subscriptionRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container
        .read(subscriptionControllerProvider.notifier)
        .purchaseSubscription();

    final state = container.read(subscriptionControllerProvider);
    expect(state.hasError, isFalse);
    expect(state.isLoading, isFalse);
  });

  test('restorePurchases exposes repository failures', () async {
    final repository = TestSubscriptionRepository(
      initialValue: false,
      failRestore: true,
    );
    addTearDown(repository.dispose);

    final container = ProviderContainer(
      overrides: [subscriptionRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container
        .read(subscriptionControllerProvider.notifier)
        .restorePurchases();

    final state = container.read(subscriptionControllerProvider);
    expect(state.hasError, isTrue);
  });
}
