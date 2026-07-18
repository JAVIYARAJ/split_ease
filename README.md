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
| 💰 **Expense Management** | Add, edit, and delete expenses with full detail view and status labels |
| 🧑‍💻 **Personal Expense Tracking** | Track private individual expenses separate from shared/group balances |
| 🧍 **Payer Selection** | Choose any group member or friend as the payer for shared expenses |
| ✂️ **Split Options** | Split equally, by custom amounts, or percentage-based allocations |
| 🤝 **Settle Up Overhaul** | Redesigned settle flow with built-in calculator and overpayment warnings |
| 💳 **Payment Methods** | Track payments/settlements using specific methods (Cash, UPI, Card, etc.) |
| 📁 **Searchable Categories** | Real-time category searching with intelligent substring-fallback icons |
| 📊 **Category Spending Limits** | Set monthly budgets in ₹ (Rupee) and view warnings in the Activity Feed |
| 💬 **Expense Comments** | Dynamic comment threads with Swipe-to-Edit/Delete actions |
| 🖼️ **Media Attachments** | Securely attach receipts and transaction images hosted on Cloudinary |
| 📄 **Enhanced PDF Receipts** | Export and preview detailed PDF summaries with full metadata |
| 👥 **Groups & Invites** | Create groups, manage admin/member roles, and share QR/invite codes |
| 🔗 **Friends System** | Send, accept, or reject friend requests with live real-time notifications |
| 📡 **Realtime Syncing** | Immediate UI updates via Supabase Realtime subscription bus |
| 📅 **Activity Feed** | Chronological log of all expenses, settlements, and limit warnings |
| 🎨 **Premium UI/UX** | Animated SliverAppBars, SmoothAnimatedFAB, and status bar color sync |

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
Media Hosting   →   Cloudinary (via cloudinary_public API integration)
Image Handling  →   image_picker + cached_network_image + file_picker
Environment     →   flutter_dotenv (Externalized .env credentials)
Calculations    →   math_expressions (for built-in calculator sheet)
Charts/Visuals  →   fl_chart (personal expense visualizations)
QR              →   qr_flutter (display) + mobile_scanner (scan)
PDF             →   pdf + flutter_pdfview
Calendar        →   table_calendar
Skeletons       →   skeletonizer (loading placeholders)
Local Storage   →   shared_preferences (first-run flag)
Animations      →   lottie + flutter_animate + custom widgets
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
│   ├── main.dart                   # Entry point; initializes GetIt DI and dotenv
│   ├── app.dart                    # MaterialApp, theme, root BlocProviders, routing
│   ├── injection_container.dart    # All GetIt registrations (single file)
│   ├── core/
│   │   ├── common/cubit/           # AppUserCubit (global auth), DataRefreshCubit
│   │   ├── config/                 # AppConfigs, FeatureFlags
│   │   ├── error/                  # Failure, AppException
│   │   ├── presentation/widgets/   # Shared UI components + animations
│   │   ├── routing/                # AppRoutes (constants), RouteGenerator
│   │   ├── secrets/                # AppSecrets — loads variables from .env
│   │   ├── services/               # RealtimeService, ImagePickerService, CloudinaryService
│   │   ├── theme/                  # AppTheme, AppColors, AppTextStyles
│   │   └── usecases/               # Base UseCase<T, Params> interface
│   └── features/
│       ├── auth/                   # Login, register, Google sign-in
│       ├── splash/                 # Session check on startup
│       ├── welcome/                # First-time-user onboarding
│       ├── home/                   # Bottom-nav shell
│       ├── friends/                # Friend list, requests, per-friend history
│       ├── groups/                 # Group list, detail, settings, create, join
│       ├── expenses/               # Add/edit/delete, splits, settle up, comments, media
│       ├── analytics/              # Expense breakdown, monthly insights & charts
│       ├── activity/               # Activity feed & limit alerts
│       ├── profile/                # Edit profile
│       └── account/                # Logout, category limits, feedback, QR display
├── assets/
│   ├── animation/                  # Lottie JSON files
│   └── images/welcome/             # Onboarding screen assets
├── android/
├── ios/
├── .env.example                    # Template for local environment variables
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

### 2. Configure environment variables

Copy the `.env.example` template to `.env` in the project root:

```bash
cp .env.example .env
```

Open `.env` and fill in your actual credentials:

```ini
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# Google Sign-In OAuth Client IDs
GOOGLE_WEB_CLIENT_ID=your_google_web_client_id.apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=your_google_ios_client_id.apps.googleusercontent.com

# Cloudinary credentials (for expense receipts/attachments)
CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
CLOUDINARY_UPLOAD_PRESET=your_cloudinary_upload_preset
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret
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

## 🗄 Supabase Backend & Database Functions

The backend relies on **Supabase** for database, auth, and real-time triggers, using robust **Postgres RPC (Remote Procedure Call) functions** to run transactional and relational business logic on the database side.

### Core tables

| Table | Purpose |
|---|---|
| `profiles` | User profile linked to `auth.users` |
| `expenses` | All expenses — amount, payer, scope (shared/personal), payment method |
| `expense_participants` | Participant list and split amount/percentage breakdowns |
| `expense_comments` | Inline comments threads per expense |
| `expense_media` | Image/receipt URLs and attachment metadata |
| `payment_methods` | System-supported payment methods (Cash, Card, UPI, etc.) |
| `category_limits` | Monthly budget thresholds per expense category |
| `groups` | Group metadata — name, icon, invite code |
| `group_members` | Group membership with role (admin / member) |
| `friends` | Friend relationships between users |
| `friend_requests` | Pending/accepted/rejected friend requests |
| `settlements` | Recorded settlements and payment records |
| `activities` | Denormalized activity feed rows (e.g. limit warning events) |

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
- [/] Subscription tier with advanced analytics (charts/breakdown implemented)
- [x] Monthly spending summary and charts
- [ ] Dark mode
- [ ] Offline-first with local queue and sync on reconnect
- [ ] Web companion app

---

<div align="center">

Built by [Javiya Raj](https://github.com/JAVIYARAJ) — Flutter developer, product builder.

*Split the bill. Not the friendship.*

</div>
