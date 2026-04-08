# Data at Bat - MLB Predictions & Analytics

Data at Bat is a Flutter application providing MLB game predictions.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)

---

## Service Integrations

The app currently uses **Mock Repositories** for local development and testing.

### Current Features

- **Daily Predictions:** View daily MLB game matchups.
- **My Subscription:** View subscription status (mocked).
- **Historical Accuracy:** View historical prediction performance.

---

## Testing Procedures

### Unit & Widget Tests

Fast tests that verify individual components and UI behavior using `mocktail` and `flutter_riverpod` overrides.

- No external dependencies required.
- Uses `MockSubscriptionRepository` and `PredictionRepository` (mock mode).

---

## Example Commands

### Run Unit and Widget Tests

```bash
flutter test
```

### Build for Production (iOS)

```bash
flutter build ios --release
```

### Build for Production (Android)

```bash
flutter build appbundle --release
```
