# Currency Rate Calculator

A Flutter app to convert currency amounts using a remote API, with Firebase Auth, BLoC state management, DI via GetIt, Dio networking, and simple local caching.

## Getting Started

---

## Prerequisites

* __Dart SDK__: >= 3.8.1 (see `pubspec.yaml -> environment.sdk`)
* __Flutter SDK__: A version compatible with Dart >= 3.8.1
* __Firebase__: Project configured (Android/iOS) with generated `firebase_options.dart`
* __Platforms__: Android, iOS (desktop/web not configured here)

---
- __Configure .env__ at repo root:
  ```env
  BASE_URL=https://api.exconvert.com
  ACCESS_KEY=YOUR_API_ACCESS_KEY
  ```
- __Install deps__: `flutter pub get`
- __Run__: `flutter run`

Notes
- __Mock mode__: not implemented. App falls back to last cached successful result if API fails.

- __Caching__: key `last_convert_result_v1` (no TTL). Stored via `shared_preferences`.

- __API failures__: Dio auto-retries (3x, 2s). On failure, tries cached result; else shows error with Retry.

---

### Folder Layout

```
lib/
  core/
    config/            # AppConfig reads .env
    data/              # (reserved/general data helpers)
    di/                # GetIt service locator (init in `injection.dart`)
    network/           # Dio client and interceptors
    storage/           # CacheService using shared_preferences
    router/            # AppRouter (navigation)
    theme/             # AppTheme (light/dark)
  features/
    auth/              # Auth repository + usecases + presentation (Cubit)
    conversion/
      data/            # CurrencyRepositoryImpl
      domain/          # Entities, repository abstraction, usecases
      presentation/    # Cubits, screens, widgets (e.g., `home_screen.dart`)
  firebase_options.dart
  main.dart            # Loads .env, initializes Firebase, DI, and runs app
```

---