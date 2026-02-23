# Data at Bat - MLB Predictions & Analytics

Data at Bat is a Flutter application providing MLB game predictions

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- [Firebase CLI](https://firebase.google.com/docs/cli) (for real Firebase integration)
- [RevenueCat Account](https://www.revenuecat.com/)
- [Google Cloud Project](https://console.cloud.google.com/) (for Google Sign-In)

---

## Service Integrations

The app is currently configured to use **Mock Repositories** for local development and testing without requiring external credentials. To switch to live services, follow the setup guides below.

### 1. Google Sign-In Setup

To implement Google OAuth 2.0 flow:

#### Google Cloud Configuration

1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project.
3. Configure the **OAuth consent screen**.
4. Create **OAuth 2.0 Client IDs** for your target platforms (Android, iOS, Web).
    - For Android: You will need the SHA-1 fingerprint of your debug and release keys.
    - For iOS: You will need the bundle identifier.
    - For Web: You will need the authorized JavaScript origins and redirect URIs.

#### Implementation

We use the `google_sign_in` package for:

- **Authentication State:** Managed via Riverpod providers.
- **OAuth 2.0 Flow:** Retrieves `accessToken` and `idToken` for further integration.
- **Error Handling:** Catches common issues like cancelled sign-ins or configuration errors.

To use the real Google Sign-In implementation, toggle `useMockAuth` to `false` in `lib/features/auth/presentation/providers/auth_provider.dart`.

---

### 2. Firebase Setup

To integrate with a real Firebase instance:

#### Environment Variables

Configure the following in your `.env` or CI environment:

- `FIREBASE_API_KEY`: Your project's API key.
- `FIREBASE_AUTH_DOMAIN`: Your project's auth domain.
- `FIREBASE_PROJECT_ID`: Your unique project ID.
- `FIREBASE_STORAGE_BUCKET`: Default storage bucket name.
- `FIREBASE_MESSAGING_SENDER_ID`: Messaging sender ID.
- `FIREBASE_APP_ID`: Application ID for your platform.

#### Service Account Key

For administrative tasks or backend integration tests:

- Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the absolute path of your Firebase service account JSON key file.

#### Firebase Emulator Suite

For safe local testing:

1. Install the emulator suite: `firebase init emulators`
2. Start the emulators: `firebase emulators:start`
3. The app can be configured to point to `localhost` for Auth, Firestore, and Functions during development.

---

### 3. RevenueCat Setup

For subscription management via RevenueCat:

#### API Configuration

- `REVENUECAT_API_KEY`: Obtain your public SDK key from the RevenueCat dashboard.
- Ensure the key is loaded securely within your `SubscriptionRepository` implementation.

#### Sandbox Testing

- **iOS:** Use a "Sandbox Tester" account in App Store Connect.
- **Android:** Use "License Testing" in the Google Play Console.
- RevenueCat automatically handles sandbox receipts when using sandbox credentials.

#### Webhooks Configuration

- Configure RevenueCat Webhooks to point to your backend/Firebase Functions to handle real-time subscription events (renewals, cancellations, etc.).

---

## Testing Procedures

### Unit & Widget Tests (with Mocks)

Fast tests that verify individual components and UI behavior using `mocktail` and `flutter_riverpod` overrides.

- No external dependencies required.
- Uses `MockAuthRepository` and `MockSubscriptionRepository`.

### Integration Tests (with Emulators/Sandbox)

Verify the interaction between the app and external services in a controlled environment.

- Use the **Firebase Emulator Suite** for Auth and DB.
- Use **RevenueCat Sandbox** for purchase flows.

### End-to-End (E2E) Tests (Live Services)

**Caution:** These tests use live services and may incur costs or create real records.

- Use dedicated staging/testing environments.
- Verify production-readiness before deployment.

---

## Example Commands

### Run Unit and Widget Tests

```bash
flutter test
```

### Run a Specific Test File

```bash
flutter test test/features/auth_flow_test.dart
```

### Start Firebase Emulators

```bash
firebase emulators:start --import=./test_data --export-on-exit
```

### Build for Production (iOS)

```bash
flutter build ios --release
```

### Build for Production (Android)

```bash
flutter build appbundle --release
```
