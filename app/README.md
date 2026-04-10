# Data at Bat - MLB Predictions & Analytics

Data at Bat is a Flutter application providing MLB game predictions.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- **Ruby & CocoaPods** (Required for iOS/macOS)
  - Install Ruby version > 3.1.0
  - Install CocoaPods: `sudo gem install cocoapods`
  - Install iOS dependencies: `cd ios && pod install`

---

## Service Integrations

The app uses **Firebase** for Authentication and currently defaults to **Mock Repositories** for local data development.

### Authentication

The app supports cross-platform authentication with a platform-native feel:
- **iOS/macOS:** Sign in with Apple & Google.
- **Android/Web:** Sign in with Google.
- **Access Policy:** The application follows a **"Logged in == Paid"** model. Once authenticated, users have full access to all prediction data.

### Core Features

- **Daily Predictions:** View daily MLB game matchups with advanced model predictions.
- **My Subscription:** Manage user account and view subscription status.
- **Historical Accuracy:** View historical prediction performance analytics.

---

## Testing Procedures

### Unit & Widget Tests

Fast tests that verify individual components and UI behavior using `mocktail` and `flutter_riverpod` overrides.

- No external dependencies required.
- Uses `MockSubscriptionRepository` and `PredictionRepository` (mock mode).

---

## Example Commands

### Install iOS Dependencies

```bash
cd ios && pod install
```

### Run Unit and Widget Tests

```bash
flutter test
```

### Run Coverage

```bash
flutter test --coverage
```

### Run Integration Smoke Tests

```bash
flutter test integration_test
```

## Testing Docs

- Audit: [docs/frontend_test_audit.md](./docs/frontend_test_audit.md)
- Guide: [docs/testing.md](./docs/testing.md)

### Build for Production (iOS)

```bash
flutter build ios --release
```

### Build for Production (Android)

```bash
flutter build appbundle --release
```
