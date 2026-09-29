# SplitEase — Case Study

> **Split the bill. Not the friendship.**
> A cross-platform bill-splitting and personal finance app built with Flutter and Supabase.

| | |
|---|---|
| **Role** | Solo developer — product, design, mobile, and backend |
| **Platforms** | iOS & Android (single Flutter codebase) |
| **Stack** | Flutter · Dart 3.9 · flutter_bloc · Supabase (Postgres, Auth, Realtime, Storage) · GetIt · fpdart · Cloudinary |
| **Type** | Personal product, end to end |
| **Links** | [GitHub](https://github.com/JAVIYARAJ/split_ease) · _App Store / Play Store link_ · _Demo video_ |

<!-- Add hero image: 3 phone mockups (Home dashboard · Add expense · Group detail) -->
![SplitEase hero](docs/case-study/hero.png)

---

## 1. The Problem

Shared money gets messy quickly. Flatmates split rent and groceries, friends split a trip, and colleagues split lunch. Over time a few problems keep coming up:

- **Nobody remembers who paid for what.** Chat threads and mental notes don't scale past a handful of expenses.
- **Real splits are rarely equal.** One person skips dinner, someone else covers 60% of the cab, and a birthday is split three ways but not four.
- **Settling up is awkward.** People avoid asking for money because they aren't sure about the exact number.
- **Shared and personal spending get mixed up.** Most split apps only track group debts, so users still need a second app for their own budget.

**Goal:** build one app that records shared expenses accurately, keeps a live running balance with every friend and group, makes settling up a one-tap action, and also covers personal spending and budgets.

---

## 2. My Role & Scope

I owned SplitEase end to end:

- **Product:** feature scoping, user flows, and prioritisation (managed with feature flags)
- **UI/UX:** screen design, motion, empty/loading states, and light/dark theming
- **Mobile engineering:** Flutter app architecture, state management, navigation, and DI
- **Backend:** Supabase schema, Row-Level Security, Postgres RPC functions, realtime channels, and media storage

---

## 3. Solution Overview

SplitEase covers the whole flow around shared money: **add → split → track → settle → analyse**.

| Area | What users can do |
|---|---|
| 💰 **Expenses** | Add, edit, and delete expenses (with undo via restore). Choose any member as payer, add a category and payment method (Cash, UPI, Card…), attach receipts, and comment in a thread |
| ✂️ **Flexible splits** | Split **equally** (select who's in), by **exact amounts**, by **percentage**, or by **shares** |
| 🤝 **Settle up** | Record a payment to a friend, optionally scoped to a group, using a built-in calculator and overpayment warnings |
| 👥 **Groups** | Create groups with icons, admin/member roles, and invite by **code or QR** (scan to join). Manage members, leave, or delete |
| 🔗 **Friends** | Send, accept, or reject friend requests with **live realtime notifications**. See per-friend expense history and common groups |
| 🧍 **Personal expenses** | Track private spending separately from shared balances, filtered by date, category, and payment method |
| 🔁 **Recurring expenses** | Save templates (rent, subscriptions) with frequency, due day, and reminders. Pause, resume, or confirm them |
| 📊 **Analytics** | Category breakdown charts with date-filtered, paginated drill-downs into transactions |
| 🎯 **Budgets** | Monthly per-category spending limits, with warnings shown in the activity feed |
| 📅 **Activity feed** | Chronological log of expenses, settlements, and limit alerts |
| 📄 **Exports** | PDF expense receipts with in-app preview and sharing |

<!-- Add a screenshot grid here: 2–3 rows of 3 screens -->

---

## 4. Architecture

### Clean Architecture, feature-first

The codebase is split into **12 self-contained feature modules** (auth, splash, welcome, home, friends, groups, expenses, analytics, recurring expenses, activity, profile, account) on top of a shared `core` layer. Every feature follows the same three-layer layout with a strict one-way dependency rule:

```
Presentation  ──►  Domain  ◄──  Data
(BLoC, pages)      (entities,    (Supabase datasources,
                    usecases,     models, repo impls)
                    repo interfaces)
```

- **Domain** is pure Dart with no Flutter or Supabase imports. Each operation is one `UseCase<T, Params>` class, such as `AddExpenseUseCase`, `SettleUpUseCase`, or `RestoreExpenseUseCase`.
- **Data** holds every Supabase call behind `*RemoteDataSource` interfaces. DTO models map JSON to entities.
- **Presentation** uses BLoC for complex screens (add expense, group settings) and Cubit for simpler state (theme, settle up, feedback).

### Typed error handling

Repositories and usecases return `Future<Either<Failure, T>>` using **fpdart**. Blocs `fold` the result into success or failure states, so errors travel as values through the app instead of escaping as exceptions. Data sources convert raw Postgres/network errors into readable messages in one place (`ErrorMessageUtils`).

### Dependency injection

All wiring lives in a single `injection_container.dart` using **GetIt**, registered in a fixed order: DataSource → Repository → UseCases → Bloc. Blocs are factories, so every screen gets fresh state. Shared services (Supabase client, realtime, refresh bus, theme) are lazy singletons.

### Routing

Named routes are defined as constants in `AppRoutes`. A switch-based `RouteGenerator` wraps each page in its own `BlocProvider`, which keeps a screen's state scoped to its lifetime.

---

## 5. Key Engineering Challenges

### Challenge 1 — Keeping money data consistent

**Problem:** Creating one expense writes to several tables: the expense row, one participant row per person with their share, media, and activity entries. If those writes ran one by one from the client, a dropped connection partway through could leave balances out of sync.

**Solution:** I moved the business logic into **Postgres RPC functions** on Supabase (`create_expense_rpc`, `update_expense_rpc`, `delete_expense_rpc`, `restore_expense_rpc`, `get_expense_detail_rpc`, recurring-expense RPCs, and more). Each mutation runs as **one transactional call**, and every RPC returns the same `{ success, message, … }` envelope. The data layer turns that envelope into a typed `Failure`, so every feature handles server errors the same way.

**Result:** Writes either complete fully or not at all. The client stays thin, and Row-Level Security enforces access rules close to the data.

### Challenge 2 — Stale screens after a mutation

**Problem:** One expense affects many screens at once: the home dashboard, the group detail, the friend detail, the activity feed, and analytics. Reloading everything after every change wastes work, but reloading nothing leaves users looking at wrong balances.

**Solution:** I built a small cross-screen **invalidation bus**, `DataRefreshCubit`, which supports two kinds of flags:

- **Global flags** for list screens (`home`, `groups`, `friends`, `activity`)
- **ID-scoped flags** for detail screens (`groupDetail:{id}`, `friendDetail:{id}`, `expenseDetail:{id}`)

After a mutation, the bloc calls `markForRefresh(type, id: …)`. Each affected screen checks `shouldRefresh` when it becomes visible and then clears its flag.

**Result:** Only the screens that actually changed refetch, and they only do it when the user returns to them. This avoids wasted network calls and stale balances.

### Challenge 3 — A split editor that handles real life

**Problem:** There are four split modes, each with different rules. In **equal** mode the user picks who is included. In **exact**, **percentage**, and **shares** modes, everyone needs an editable input. Switching between modes can't lose data or quietly add people back in.

**Solution:** I built a dedicated `SplitBloc` that owns all split logic, separate from the UI:

- In **equal** mode, the split list works as the *selected set*. Toggling a member, or using select-all, recalculates `total / selectedCount` immediately.
- In the other modes, the bloc makes sure every member has an entry (defaulting to 1 share) without resetting values already entered.
- Editing an existing expense seeds the bloc from the saved splits, so the editor opens exactly as the expense was saved.

**Result:** The screens stay simple, and the split rules sit in one testable place.

### Challenge 4 — Realtime friend requests without polling

**Problem:** Users expect incoming friend requests to show up immediately, but polling drains battery and adds server load.

**Solution:** `RealtimeService` subscribes to Supabase Realtime **Postgres change events** on the friendship table, filtered server-side to `addressee_id = currentUser` and to pending requests only. When an event arrives, it fetches the requester's profile to build a proper notification. If that lookup fails, it still delivers a fallback notification, so the request is never dropped. Before resubscribing, the service tears down the old channel to avoid duplicate listeners.

### Challenge 5 — Safe deletes

Deleting an expense changes balances for everyone involved, so a mistaken delete is costly. Expenses are **soft-deleted** and can be restored through a dedicated `restore_expense_rpc`. This makes an undo possible without a trip to support.

---

## 6. Design & UX Details

- **Motion with a purpose:** animated SliverAppBars, a smooth animated FAB, Lottie animations, and `flutter_animate` transitions, including an animated circular avatar preview
- **Perceived performance:** skeleton loaders (`skeletonizer`) instead of spinners, plus cached network images
- **Light / dark / system theme:** saved with a `ThemeCubit` backed by `SharedPreferences`
- **Onboarding:** a first-run welcome flow, tracked locally so it only appears once
- **Empty states** designed for new users (for example, personal analytics before enough data exists)
- **Useful extras:** a built-in calculator (`math_expressions`) in amount fields, a calendar date picker, and QR display/scan for invites
- **Feature flags** (`isSocialAuthEnabled`, `isForgotPasswordEnabled`, `isSubscriptionEnabled`) let unfinished features ship dark and be switched on later

---

## 7. Tech Stack

| Layer | Choice | Why |
|---|---|---|
| UI | Flutter 3.x, Dart 3.9 | One codebase for iOS and Android with native-feeling performance |
| State | flutter_bloc (BLoC + Cubit) | Predictable, event-driven state that is easy to test |
| Backend | Supabase (Postgres, Auth, Realtime, Storage) | Relational data suits ledgers, and RLS plus RPCs remove the need for a custom server |
| Auth | Email/password + Google Sign-In | Low-friction sign-up |
| DI | get_it | Simple service locator that keeps each layer swappable |
| Errors | fpdart `Either` | Errors are explicit, typed return values |
| Media | Cloudinary + image_picker / file_picker | Receipt and image hosting |
| Charts | fl_chart | Category breakdown and spending insights |
| Docs | pdf + flutter_pdfview + share_plus | Exportable, shareable receipts |
| QR | qr_flutter + mobile_scanner | Group invites in person |
| Config | flutter_dotenv | Secrets kept out of source control |

---

## 8. Outcomes

<!-- Replace these with real numbers where you have them (users, groups created, expenses logged, store rating, crash-free rate). -->

- Shipped a **full-featured app** covering the whole shared-money lifecycle, plus personal budgeting, from one Flutter codebase
- **12 feature modules** built with the same Clean Architecture pattern, which made adding later features (recurring expenses, analytics, budgets) straightforward
- **No custom server to run or maintain:** business logic lives in Postgres RPCs and is secured with RLS
- _Add metrics: e.g. "X active users", "Y expenses tracked", "store rating Z"_

---

## 9. What I Learned

- **Put money logic in the database.** Transactional RPCs gave me correctness guarantees that would have been hard to achieve with many separate client-side writes.
- **Architecture pays off as the app grows.** The first features were slower to build, but analytics, recurring expenses, and budgets slotted in without touching existing code.
- **Cache invalidation is a product problem as well as a technical one.** Showing a wrong balance, even briefly, damages trust, which is why the refresh bus was worth building.
- **Feature flags reduce launch risk.** I could merge work-in-progress safely and turn features on when they were ready.

---

## 10. What's Next

- **Debt simplification:** reduce the number of payments needed to settle a group
- **Push notifications** for new group expenses and settlement reminders
- **Offline-first:** a local write queue that syncs when the connection returns
- **Multi-currency** support for trips abroad
- **Password reset** and a **Pro tier** (both already behind feature flags)
- **Wider automated test coverage** for the split and settle-up logic

---

<div align="center">

**Built by [Javiya Raj](https://github.com/JAVIYARAJ)** — Flutter developer & product builder

</div>
