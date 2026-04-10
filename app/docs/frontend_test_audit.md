# Frontend Test Audit

This audit covers the Flutter frontend in `/app` and tracks current automated coverage, major gaps, and the recommended next layer of testing.

## Coverage Snapshot

| Area | Current status | Existing automated coverage | Main gaps | Risk |
| --- | --- | --- | --- | --- |
| Router guards | partially covered | Route inventory assertions; authenticated app shell launch | Redirect behavior for unauthenticated users and login/signup redirects | High |
| Daily predictions | partially covered | Empty state, happy-path render, tap-through to detail | Loading, error, multiple-game rendering, asset fallback, value badge variants | High |
| Login | untested | None | Success, loading, trimmed credentials, error handling | High |
| Signup | untested | None | Success, loading, trimmed credentials, error handling | High |
| Change password | untested | None | Local validation, success snackbar, repository error path | High |
| Profile | untested | None | Auth-state rendering and navigation to change password | Medium |
| Settings | untested | None | Profile navigation, sign-out dialog cancel/confirm behavior | High |
| Subscription providers | untested | None | Stream state updates, controller success/error transitions | Medium |
| Integration journeys | untested | None | Protected launch, main-shell navigation, detail drill-in, profile flow smoke | High |

## Current Test Assets

- `flutter_test` and `mocktail` are already configured.
- Existing tests live under `/app/test/shared`.
- CI already runs `flutter analyze` and Flutter tests in [.github/workflows/CI_test_suite.yml].

## Immediate Priorities

1. Expand widget and provider coverage around auth, router redirects, daily predictions states, settings, profile, and subscription state transitions.
2. Add reusable fixtures and provider override helpers so new tests stay small and consistent.
3. Add a thin `integration_test/` smoke suite for the highest-value user journeys.
4. Capture line coverage in CI and publish the LCOV artifact for trend tracking.

## Manual Checks That Still Matter

- Firebase auth against the dev project.
- Session persistence after sign-out and relaunch.
- Asset rendering on mobile and web.
- Smoke test on at least one simulator and one web build.
