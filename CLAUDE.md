# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SplitEase is a Flutter bill-splitting app (similar to Splitwise) backed by Supabase. Users track expenses, split bills with friends/groups, and settle up balances.

**Flutter version:** Managed by FVM (`stable` channel). Use `fvm flutter` instead of `flutter` if FVM is active.

## Commands

```bash
# Run the app
flutter run

# Analyze (lint)
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Get dependencies
flutter pub get
```

## Architecture

Strict **Clean Architecture** with a unidirectional dependency rule: Presentation → Domain ← Data.

```
lib/
├── main.dart                  # Entry point; calls injection_container.dart init()
├── app.dart                   # MaterialApp, theme, global BlocProviders, routing
├── injection_container.dart   # All GetIt DI registrations (single file)
├── core/                      # Cross-feature utilities
│   ├── common/cubit/          # AppUserCubit (global auth state), DataRefreshCubit
│   ├── config/                # AppConfigs, FeatureFlags (feature toggles)
│   ├── error/                 # Failure class (returned from repos)
│   ├── routing/               # AppRoutes (constants), RouteGenerator (switch-based)
│   ├── secrets/               # AppSecrets (Supabase URL + anon key)
│   ├── services/              # RealtimeService (Supabase realtime), ImagePickerService, DataRefreshCubit
│   ├── theme/                 # AppTheme, AppColors, AppTextStyles
│   └── usecases/              # Base UseCase<SuccessType, Params> interface
└── features/
    ├── auth/                  # Login, register, Google sign-in
    ├── splash/                # Session check on startup
    ├── welcome/               # First-time-user onboarding
    ├── home/                  # Bottom-nav shell
    ├── friends/               # Friend list, requests, friend detail with expense history
    ├── groups/                # Group list, detail, settings, create, join via invite code/QR
    ├── expenses/              # Add/edit/delete expense, payer selection, split options, settle up
    ├── activity/              # Activity feed
    ├── profile/               # Edit profile
    └── account/               # Logout, feedback, QR code display
```

Each feature follows the same internal layout:
```
feature/
├── data/
│   ├── datasources/   # *RemoteDataSource (Supabase calls)
│   ├── models/        # DTOs extending domain entities, with fromMap/toMap
│   └── repository/    # *RepositoryImpl implementing domain interface
├── domain/
│   ├── entities/      # Plain Dart classes, no external deps
│   ├── repositories/  # Abstract interfaces
│   └── usecases/      # One class per operation; implements UseCase<T, Params>
└── presentation/
    ├── bloc/          # BLoC/Cubit; add event → call usecase → emit state
    ├── pages/         # Full screens
    └── widgets/       # Feature-scoped UI components
```

## Key Patterns

### Return Types
All usecases and repository methods return `Future<Either<Failure, T>>` using `fpdart`. Blocs fold the result to emit success/failure states.

### Dependency Injection
`injection_container.dart` is the single DI file. Registration rules:
- **`registerFactory`** — Blocs/Cubits (fresh instance per screen)
- **`registerLazySingleton`** — Repositories, data sources, services (shared, created on first use)
- **`registerSingleton`** — Reserved for things that must be ready at startup

When adding a new feature, register in `injection_container.dart` following the pattern: DataSource → Repository → UseCases → Bloc.

### Routing
All routes are named constants in `AppRoutes`. `RouteGenerator.generateRoute` is a switch-case that wraps each page in a `BlocProvider` pulling from `sl<>`. Pass arguments via `RouteSettings.arguments` (usually a `Map<String, dynamic>` or a typed entity).

### Global State
- **`AppUserCubit`** — holds the currently logged-in `UserEntity`; provided at root in `app.dart`
- **`DataRefreshCubit`** — cross-screen invalidation bus; call `markForRefresh(RefreshType.X)` after mutations, check `shouldRefresh` in target screens

### Realtime
`RealtimeService` wraps Supabase realtime channels. Currently used for live friend-request notifications.

### Feature Flags
`lib/core/config/feature_flags.dart` — static booleans. Check these before implementing UI for gated features (`isSocialAuthEnabled`, `isForgotPasswordEnabled`, `isSubscriptionEnabled`).

## Backend

**Supabase** is the sole backend (auth + database + realtime + storage). Credentials are in `lib/core/secrets/app_secrets.dart` (not committed — create this file locally if missing). The Supabase client is registered as a lazy singleton and injected wherever needed.

## State Management

**flutter_bloc** with BLoC pattern for complex screens, Cubit for simpler state. No Riverpod or Provider is used despite the README mentioning them (the README is outdated).
