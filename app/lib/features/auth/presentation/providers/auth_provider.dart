import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/features/auth/data/repositories/auth_repository.dart';

// Provides the Firebase Auth instance
final authProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Provides your custom Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repository = AuthRepository();
  // Ensure your AuthRepository class actually has a dispose method
  ref.onDispose(repository.dispose);
  return repository;
});

// Watches the logged-in state (for the router/UI)
final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});