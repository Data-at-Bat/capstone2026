import 'dart:async';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final _controller = StreamController<String?>.broadcast();
  String? _currentUser;

  MockAuthRepository();

  @override
  Stream<String?> get authStateChanges async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  String? get currentUser => _currentUser;

  @override
  Future<void> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = 'mock_google_user_id';
    _controller.add(_currentUser);
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _controller.add(null);
  }
}
