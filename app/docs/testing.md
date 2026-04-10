# Frontend Testing Guide

This app uses a small testing pyramid:

## Test Layers

- Widget and provider tests are the default for UI states, validation, navigation, and repository/provider interactions.
- Integration smoke tests cover a few end-to-end journeys through the real app shell with mocked providers.
- Manual exploratory checks cover Firebase-backed and platform-specific behavior that is still expensive to automate.

## Commands

```bash
flutter test
flutter test --coverage
flutter test integration_test
```

## Conventions

- Put shared fixtures and mocks under `/app/test/support`.
- Prefer `ProviderScope` overrides to isolate repository and auth behavior.
- Keep widget tests focused on happy path, loading state, and error state for each screen.
- Keep integration tests small and stable; use them for app-shell flow, not exhaustive UI assertions.

## What Belongs Where

- Widget and provider tests:
  - Auth screen validation and async button states
  - Router redirect behavior
  - Daily predictions data/loading/error rendering
  - Settings and profile UI behavior
  - Subscription provider transitions
- Integration tests:
  - Protected launch to login
  - Authenticated app-shell navigation
  - Game detail drill-in
  - Profile and change-password navigation flow
- Manual checks:
  - Real Firebase sign-in/sign-out
  - Platform rendering smoke checks
  - Web and simulator sanity passes

## Coverage Policy

- CI generates `coverage/lcov.info` on every frontend test run.
- The initial target is 60% overall frontend line coverage.
- Coverage is tracked as a trend signal first; do not block work on day one solely for falling short of the initial target.

## Manual Frontend Smoke Checklist

1. Launch the app on a simulator and on web.
2. Confirm unauthenticated users land on the login screen.
3. Sign in against the dev Firebase project.
4. Open daily predictions and drill into one matchup.
5. Navigate to settings, profile, and change password.
6. Sign out and confirm the next app launch returns to login.
7. Verify team logo assets render on both mobile and web.
