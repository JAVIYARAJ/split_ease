# SplitEase: Bill Splitting, Settle-Up & Personal Finance App

> A cross-platform Flutter app where friends, flatmates and trip groups log shared expenses, split them any way they like, settle up in one tap, and also track their own spending and budgets.

![SplitEase hero image](./images/splitease-hero.png)
<!-- Replace with a mockup of 3–4 key screens (Home dashboard, Add expense, Split options, Group detail) -->

| | |
|---|---|
| **Project** | SplitEase (personal product) |
| **My role** | Solo developer: product, UI/UX, Flutter app and Supabase backend |
| **Platforms** | iOS & Android |
| **Timeline** | Started Jan 2026 · in active development |
| **Team** | Just me |
| **Stack** | Flutter, Dart, flutter_bloc, Supabase (Postgres, Auth, Realtime, Storage), GetIt, fpdart, Cloudinary, fl_chart |

---

## Overview

Splitting money with other people is simple for one dinner, but it gets messy over a month of rent, groceries, cabs and trips. People forget who paid, splits are rarely equal, and asking a friend for money is awkward when you aren't sure of the exact amount.

**SplitEase keeps a running, accurate balance with every friend and group.** Users add an expense, choose who paid and how to split it, and the app shows who owes whom. When it's time to pay, settling up takes one tap.

I also didn't want users to need a second app for their own money. So SplitEase also tracks **personal expenses**, **recurring bills**, **monthly category budgets** and **spending analytics**, all in the same place as shared balances.

---

## The Challenge

- **Money data has to be correct.** A single expense touches the expense record, every participant's share, attachments and the activity feed. A half-finished write means wrong balances, and users stop trusting the app.
- **Real splits aren't equal.** The app had to support equal, exact-amount, percentage and share-based splits, and keep them correct while members are added, removed and switched between modes.
- **One change affects many screens.** An expense changes the home dashboard, the group, the friend's page, the activity feed and analytics. Each of those needed to update without reloading everything all the time.
- **Social features need to feel live.** Friend requests should appear as soon as they are sent, without polling.
- **Building it solo.** With no team, the codebase had to stay easy to extend as features piled up.

---

## What I Built

### 1. Expenses and flexible splits
- Add, edit and delete expenses, with **undo via restore** (soft delete).
- Pick **any member as the payer**, and set a category, payment method (Cash, UPI, Card…), date and notes.
- **Four split modes:** equal (choose who's included), exact amounts, percentage and shares.
- A **built-in calculator** in the amount field (`math_expressions`), plus a calendar date picker.
- Attach receipts and images (hosted on **Cloudinary**), and discuss each expense in a **comment thread** with swipe-to-edit or delete.
- Export any expense as a **PDF receipt**, with in-app preview and sharing.

### 2. Settle up
- Record a payment to a friend, optionally within a specific group.
- Choose a payment method, add a note and set a date.
- **Overpayment warnings** stop users from paying more than they owe.

### 3. Groups
- Create groups with a custom icon, and manage **admin / member roles**.
- Invite people with an **invite code** or a **QR code**, and join by scanning with `mobile_scanner`.
- The group dashboard shows balances and full expense history. Admins can add friends, remove members, change roles, leave or delete the group.

### 4. Friends
- Send, accept and reject friend requests, with **real-time notifications** and an unread badge.
- A friend detail dashboard shows per-friend balance, shared expense history and groups in common.
- A personal **QR code** so people can add you in person.

### 5. Personal finance
- **Personal expenses** tracked separately from shared balances, filterable by date range, category and payment method.
- **Recurring expenses**: templates for rent, subscriptions and bills, with frequency, due day and reminders. They can be paused, resumed and confirmed.
- **Monthly category limits** (budgets). The activity feed warns you when you're close to a limit.
- **Analytics**: category breakdown charts (`fl_chart`) with a **date-filtered, paginated drill-down** into the transactions behind each category.

### 6. Platform features
- Sign-in with **email/password** and **Google**, including email-confirmation resend.
- Onboarding for first-time users, and a **paginated activity feed**.
- **Light, dark and system themes**, saved on the device.
- Home dashboard with summary cards and promotional banners.
- In-app feedback with ratings, profile editing with avatar upload, and an animated avatar preview.
- **Feature flags** for social auth, forgot password and a future Pro subscription, so unfinished features ship switched off.

---

## Architecture

The app is **~43k lines of Dart across 356 files**, built on **Clean Architecture** with a feature-first layout:

```
lib/
├── main.dart                 # Entry point, loads .env and DI
├── app.dart                  # MaterialApp, themes, root BlocProviders
├── injection_container.dart  # All GetIt registrations in one file
├── core/                     # Theme, routing, errors, services, shared widgets, global cubits
└── features/                 # 12 feature modules, each with:
    └── <feature>/
        ├── data/             # Remote data sources (Supabase) → models → repository impls
        ├── domain/           # Entities, repository interfaces, usecases
        └── presentation/     # BLoC / Cubit, pages, widgets
```

**Key rules I followed:**
- **Dependencies point one way:** `presentation → domain ← data`. The domain layer is pure Dart and never imports Flutter or Supabase.
- **One usecase per operation:** 65 usecases, such as `AddExpenseUseCase`, `SettleUpUseCase` and `RestoreExpenseUseCase`.
- **Errors are values, not exceptions.** Every repository and usecase returns `Either<Failure, T>` (**fpdart**), and blocs `fold` the result into states.
- **flutter_bloc** for state (33 blocs and cubits): BLoC for complex screens like Add Expense, and Cubit for simpler ones like theme and settle-up.
- **GetIt** for DI, registered in a fixed order (DataSource → Repository → UseCases → Bloc). Blocs are factories, so every screen starts with fresh state.
- **Named routes** with a switch-based `RouteGenerator` that wraps each page in its own `BlocProvider`.
- **Secrets** are loaded from `.env` and never hard-coded.

---

## Engineering Highlights

| Problem | Solution |
|---|---|
| Multi-table writes leaving balances inconsistent | Business logic moved into **45 Postgres RPC functions** on Supabase. Each create, update, delete or settle-up runs as **one transactional call** and returns a shared `{ success, message }` shape that the data layer maps to a typed `Failure` |
| Screens showing stale balances after a change | A cross-screen **invalidation bus** (`DataRefreshCubit`) with global flags for lists and **ID-scoped flags** for detail pages, so only affected screens refetch when the user returns to them |
| Split rules getting tangled in UI code | A dedicated **`SplitBloc`** owns all four split modes. In equal mode the split list is the selected set and amounts are recalculated on every toggle; the other modes keep entered values when members change |
| Friend requests needing to feel instant | **Supabase Realtime** subscription on friendship inserts, filtered server-side to the current user and pending status, with a fallback notification if the profile lookup fails |
| Too many round-trips to build a dashboard | Server-side **dashboard RPCs** (`get_group_detail_dashboard_rpc`, `get_friend_detail_dashboard_rpc`) return everything a screen needs in one call |
| Long lists (activity feed, category transactions) | **Paginated RPCs** with infinite scroll, plus skeleton loaders (`skeletonizer`) instead of spinners |
| Accidental deletes of shared expenses | **Soft delete + `restore_expense_rpc`**, so a delete can be undone |

---

## Backend: Supabase as the Server

- **Postgres** for relational data such as profiles, expenses, participants, groups, members, friendships, settlements, comments, media, category limits, recurring templates and activities.
- **Row-Level Security** so users can only read and change data they are part of.
- **RPC functions** hold the business rules, which keeps the Flutter client thin and means there's no custom server to run.
- **Realtime** channels for live friend requests.
- **Storage** for avatars and group icons, and **Cloudinary** for expense receipts.

---

## Results

- Built and shipped a full bill-splitting app **on my own**: **12 feature modules, 36 screens, 65 usecases and 45 backend RPCs**.
- **~43k lines of Dart** across **90 commits** since January 2026, all of them mine.
- Grew from a basic split tracker into a **personal finance app** with recurring expenses, budgets and analytics, without rewriting earlier features.
- One Flutter codebase for **iOS and Android**, with no backend server to maintain.

<!-- Add real usage numbers if you have them (users, groups created, expenses logged, store rating). They make the strongest case. -->

---

## What I Learned

- **Money logic belongs in the database.** Transactional RPCs gave me correctness guarantees that many separate client-side writes never could.
- **Clean Architecture pays off as a solo developer.** The first features were slower to build, but analytics, recurring expenses and budgets later slotted in without touching existing code.
- **Cache invalidation is a trust issue.** Even a brief wrong balance makes users doubt the app, and that made the refresh bus worth building.
- **Feature flags reduce launch risk.** I could merge unfinished work safely and switch it on when it was ready.

---

## Screenshots

<!-- Replace with real screenshots -->
| Home | Add Expense | Split Options | Group Detail | Analytics |
|---|---|---|---|---|
| ![](./images/home.png) | ![](./images/add-expense.png) | ![](./images/split.png) | ![](./images/group.png) | ![](./images/analytics.png) |

---

**Links:** [App Store](#) · [Google Play](#) · [GitHub](https://github.com/JAVIYARAJ/split_ease)
