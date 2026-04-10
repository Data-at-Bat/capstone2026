import 'package:app/features/auth/data/repositories/auth_repository.dart';
import 'package:app/features/daily_predictions/data/repositories/prediction_repository.dart';
import 'package:app/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockPredictionRepository extends Mock implements PredictionRepository {}

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

class MockUser extends Mock implements User {}
