<div align="center">

# 💸 SplitEase — Smart Expense Splitting

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?style=flat-square&logo=supabase&logoColor=white)](https://supabase.com)
[![License](https://img.shields.io/badge/License-Private-red?style=flat-square)](./LICENSE)

*Add an expense. Split it instantly. Settle up with one tap.*

</div>

---

## 📖 What is SplitEase?

SplitEase is a Flutter bill-splitting app backed by Supabase — built for friends, flatmates, and trip groups who want to track shared expenses without the mental overhead. Add an expense, choose who's involved and how to split, and the app keeps a running tally of who owes whom.

> Built with Flutter + BLoC + Supabase. Runs on iOS and Android. No backend servers to manage.

---

## ✨ Features

| Feature | Description |
|---|---|
| 💰 **Expense Management** | Add, edit, and delete expenses with full detail view and comments |
| 🧍 **Payer Selection** | Choose any group member or friend as the payer |
| ✂️ **Split Options** | Equal split, custom amounts, or percentage-based splits |
| 🤝 **Settle Up** | Settle balances with a friend or group member; record payments |
| 📄 **PDF Export** | Generate and preview a PDF summary of any expense |
| 👥 **Groups** | Create groups, invite via QR code or invite code, manage roles |
| 🔗 **Friends** | Send/respond to friend requests; view per-friend expense history |
| 📡 **Realtime Notifications** | Live friend request alerts via Supabase Realtime |
| 📅 **Activity Feed** | Chronological log of all transactions and settlements |
| 🧾 **Expense Notes** | Attach notes and comments to individual expenses |
| 🖼 **Profile & Avatar** | Edit profile, upload photo to Supabase Storage |
| 📱 **QR Friend-Adding** | Display your personal QR code; scan others to add friends instantly |
| 🗓 **Date Picker** | Calendar-based date selection for expenses |

---

## 🛠 Tech Stack

```
UI Framework    →   Flutter 3.x + Dart 3.9+
State Mgmt      →   flutter_bloc (BLoC + Cubit pattern)
Navigation      →   Named routes via RouteGenerator (switch-case)
Backend         →   Supabase (PostgreSQL + Auth + Storage + Realtime)
Auth            →   Supabase Auth (email/password + Google Sign-In)
DI              →   get_it (service locator, `sl` singleton)
Error Handling  →   fpdart Either<Failure, T>
Image Handling  →   image_picker + cached_network_image
QR              →   qr_flutter (display) + mobile_scanner (scan)
PDF             →   pdf + flutter_pdfview
Calendar        →   table_calendar
Skeletons       →   skeletonizer (loading placeholders)
Local Storage   →   shared_preferences (first-run flag)
Animations      →   lottie + custom staggered entry widgets
Fonts           →   google_fonts
```

---

## 🏛 Architecture

SplitEase follows **Clean Architecture** per feature, with a strict unidirectional dependency rule:

```
Presentation → Domain ← Data
```

Each feature is fully self-contained with three layers — domain knows nothing about Flutter or Supabase:

```
feature/
├── domain/
│   ├── entities/       # Pure Dart entities (no framework deps)
│   ├── repositories/   # Abstract interfaces
│   └── usecases/       # Single-responsibility use cases (fpdart Either)
├── data/
│   ├── models/         # JSON ↔ entity mappers (fromMap / toMap)
│   ├── datasources/    # *RemoteDataSource — all Supabase calls live here
│   └── repository/     # Concrete *RepositoryImpl
└── presentation/
    ├── bloc/           # *_bloc.dart, *_event.dart, *_state.dart
    ├── pages/          # Full-screen pages
    └── widgets/        # Feature-scoped UI components
```

> State management is **BLoC only** — no Riverpod, no Provider.

---

## 📁 Project Structure

```
split_ease/
├── lib/
│   ├── main.dart                   # Entry point; initialises GetIt DI
│   ├── app.dart                    # MaterialApp, theme, root BlocProviders, routing
│   ├── injection_container.dart    # All GetIt registrations (single file)
│   ├── core/
│   │   ├── common/cubit/           # AppUserCubit (global auth), DataRefreshCubit
│   │   ├── config/                 # AppConfigs, FeatureFlags
│   │   ├── error/                  # Failure, AppException
│   │   ├── presentation/widgets/   # Shared UI components + animations
│   │   ├── routing/                # AppRoutes (constants), RouteGenerator
│   │   ├── secrets/                # AppSecrets — not committed, create locally
│   │   ├── services/               # RealtimeService, ImagePickerService
│   │   ├── theme/                  # AppTheme, AppColors, AppTextStyles
│   │   └── usecases/               # Base UseCase<T, Params> interface
│   └── features/
│       ├── auth/                   # Login, register, Google sign-in
│       ├── splash/                 # Session check on startup
│       ├── welcome/                # First-time-user onboarding
│       ├── home/                   # Bottom-nav shell
│       ├── friends/                # Friend list, requests, per-friend history
│       ├── groups/                 # Group list, detail, settings, create, join
│       ├── expenses/               # Add/edit/delete, payer, splits, settle up, PDF
│       ├── activity/               # Activity feed
│       ├── profile/                # Edit profile
│       └── account/                # Logout, feedback, QR display
├── assets/
│   ├── animation/                  # Lottie JSON files
│   └── images/welcome/             # Welcome screen assets
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (`stable` channel) — or [FVM](https://fvm.app/) for version management
- A [Supabase](https://supabase.com/) project (free tier works)

### 1. Clone the repository

```bash
git clone https://github.com/JAVIYARAJ/split_ease.git
cd split_ease
```

### 2. Configure Supabase credentials

Create `lib/core/secrets/app_secrets.dart` — this file is not committed:

```dart
class AppSecrets {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the app

```bash
flutter run
```

---

## 🗄 Supabase Backend

### Core tables

| Table | Purpose |
|---|---|
| `profiles` | User profile linked to `auth.users` |
| `expenses` | All expenses — amount, payer, group/friend scope |
| `expense_participants` | Who is involved in each expense and their share |
| `expense_comments` | Per-expense comment thread |
| `groups` | Group metadata — name, icon, invite code |
| `group_members` | Membership with role (admin / member) |
| `friends` | Friend relationships between users |
| `friend_requests` | Pending/accepted/rejected requests |
| `settlements` | Recorded payments between two users |
| `activities` | Denormalised activity feed rows |

### Storage buckets

| Bucket | Access |
|---|---|
| `avatars` | Private — owner RLS |
| `group-icons` | Private — member RLS |

### Realtime

`RealtimeService` subscribes to `friend_requests` inserts scoped to the current user, pushing live badge counts and notifications without polling.

---

## 🔑 Key Patterns

**Return types** — all usecases and repository methods return `Future<Either<Failure, T>>`. Blocs `fold` the result to emit success or failure states.

**DI registration order** — in `injection_container.dart`: DataSource → Repository → UseCases → Bloc. Use `registerFactory` for Blocs/Cubits, `registerLazySingleton` for everything else.

**Cross-screen invalidation** — call `DataRefreshCubit.markForRefresh(RefreshType.X)` after any mutation; target screens check `shouldRefresh` in `initState` to re-fetch.

**Routing** — all route names are constants in `AppRoutes`. `RouteGenerator.generateRoute` wraps each page in a `BlocProvider` pulling from `sl<>`. Arguments passed via `RouteSettings.arguments` (typed entity or `Map<String, dynamic>`).

---

## 🚩 Feature Flags

Controlled in `lib/core/config/feature_flags.dart`:

| Flag | Status | Description |
|---|---|---|
| `isSocialAuthEnabled` | ✅ Enabled | Google Sign-In on login screen |
| `isForgotPasswordEnabled` | ❌ Disabled | Password reset flow |
| `isSubscriptionEnabled` | ❌ Disabled | Pro subscription paywall |

---

## ⚡ Available Commands

```bash
flutter run                                       # Run on connected device
flutter run --release                             # Release build on device
flutter build apk                                 # Android APK
flutter build ipa                                 # iOS archive
flutter pub get                                   # Install dependencies
flutter pub run flutter_launcher_icons            # Regenerate launcher icons
flutter analyze                                   # Static analysis (lint)
flutter test                                      # Run all tests
flutter test test/path/to/test_file.dart          # Run a single test file
```

---

## 🗺 Roadmap

- [ ] Forgot password / email reset flow
- [ ] Push notifications for new expenses in groups
- [ ] Subscription tier with advanced analytics
- [ ] Monthly spending summary and charts
- [ ] Dark mode
- [ ] Offline-first with local queue and sync on reconnect
- [ ] Web companion app

---

<div align="center">

Built by [Javiya Raj](https://github.com/JAVIYARAJ) — Flutter developer, product builder.

*Split the bill. Not the friendship.*

</div>
