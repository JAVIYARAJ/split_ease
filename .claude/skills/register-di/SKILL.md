---
name: register-di
description: Register a class (data source, repository, usecase, bloc, cubit, service) with GetIt in lib/injection_container.dart using the right registration method. Use when adding a new injectable, fixing "Object/factory not found" errors, or refactoring existing DI.
---

# Register a class with GetIt

The single source of truth is `lib/injection_container.dart`. The `sl` constant is `GetIt.instance`. All wiring lives in `_core()` (system services) and `_features()` (per-feature blocks). The project's reasoning for each registration method is documented in `DEPENDENCY_INJECTION.md`.

## Rules — which method to use

| Class type | Method | Why |
|---|---|---|
| **Bloc / Cubit / ViewModel** | `registerFactory` | Each screen instance gets fresh state. Reusing a bloc across screen recreations causes stale state. |
| **Repository** (interface → impl) | `registerLazySingleton<Interface>` | One instance, created on first use. Repos are stateless wrappers — duplicating wastes memory. |
| **Remote/local data source** | `registerLazySingleton<Interface>` | Same reasoning as repos. |
| **Usecase** | `registerLazySingleton` | Stateless; one instance is enough. |
| **External client** (`SupabaseClient`, `SharedPreferences`, `ImagePicker`) | `registerLazySingleton` | Heavy to construct, must be a singleton. Init in `_core()`. |
| **Cross-feature service** (`DataRefreshCubit`, `RealtimeService`, `AppUserCubit`) | `registerLazySingleton` | Shared state across features; must be the same instance everywhere. |
| **Config/secrets that must exist before first frame** | `registerSingleton` | Eager — created at startup. Use sparingly; slows app launch. |

**Codebase note:** existing code is inconsistent — `_group()`, `_auth()`, `_splash()` use `registerFactory` for repos and data sources, while `_expense()` uses `registerLazySingleton`. The lazy-singleton form is correct per `DEPENDENCY_INJECTION.md` and should be used for new code. Don't "fix" existing factory registrations unless asked.

## Where to put the registration

- **System-level** (clients, storage, services, app-wide cubits) → `_core()`.
- **Feature-level** → existing `_<feature>()` block, or a new one called from `_features()`.

Order inside a feature block (mirrors call direction):
1. Data source (interface → impl)
2. Repository (interface → impl)
3. Usecases
4. Bloc / Cubit (always last)

## Patterns

### Interface-bound registration

When a class has an abstract interface (most repos and data sources do), register against the **interface type** so consumers depend on the abstraction:

```dart
sl.registerLazySingleton<ExpenseRepository>(
  () => ExpenseRepositoryImpl(remoteDataSource: sl()),
);
```

Without the type arg, `sl<ExpenseRepository>()` will throw — only `sl<ExpenseRepositoryImpl>()` would resolve.

### Concrete (no interface)

Usecases and blocs are normally concrete classes — no type arg needed:

```dart
sl.registerLazySingleton(() => GetActivityFeedUseCase(sl()));
sl.registerFactory(() => ActivityBloc(getActivityFeedUseCase: sl()));
```

### Resolving dependencies

Inside the factory body, call `sl()` (type-inferred) or `sl<ExplicitType>()` for clarity. Use the explicit form when the constructor takes multiple `sl()` calls of similar shape — easier to read at a glance.

### Async startup work

Async setup goes in `_core()` only — `_features()` is sync. Pattern:

```dart
final sharedPreferences = await SharedPreferences.getInstance();
sl.registerLazySingleton(() => sharedPreferences);
```

Note: this passes the already-resolved instance through a closure — it's lazy in name only, but that's fine because the `await` already happened.

## Common mistakes (and the symptom)

- **Forgot to register a new usecase** → runtime: `Object/factory of type X is not registered inside GetIt`. Add the `registerLazySingleton(() => XUseCase(sl()))` line.
- **Bloc gained a new constructor arg, factory not updated** → same runtime error, but for a class that *is* registered. Always update the bloc's `registerFactory(...)` block when you change its constructor.
- **Registered impl instead of interface** → consumers asking for the interface type get "not registered". Use `sl.registerLazySingleton<Interface>(() => Impl(...))`.
- **Used `registerSingleton` for a bloc** → bloc state never resets when the user leaves and re-enters the screen. Use `registerFactory`.
- **Used `registerLazySingleton` for a screen-scoped cubit holding form state** → form data leaks across navigations. Use `registerFactory`.
- **Forgot to call `_<feature>()` from `_features()`** → entire feature's deps missing at runtime. Always wire the new helper into `_features()`.

## Verification after editing

- [ ] `flutter analyze` passes.
- [ ] App boots without GetIt registration errors.
- [ ] If the class has an interface, registration uses `<Interface>`.
- [ ] New `_<feature>()` helper (if added) is called from `_features()`.
- [ ] Bloc constructor signature matches its `registerFactory(...)` arg list.
