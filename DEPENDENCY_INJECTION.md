# Dependency Injection with GetIt in Flutter

## 1. What is GetIt?

**GetIt** is a simple yet powerful **Service Locator** for Dart and Flutter.

Instead of passing data or services manually through every widget constructor (a problem known as "Prop Drilling"), GetIt allows you to store your classes (Services, Repositories, Blocs) in a central registry. When any part of your app needs a class, it simply asks GetIt for the instance.

Think of it as a **Global Tool Belt**: instead of carrying a hammer from the garage to the kitchen to the bedroom, you put the hammer in the tool belt (GetIt), and you can pull it out instantly wherever you are standing.

---

## 2. Why Do We Need It?

Using Dependency Injection (DI) via GetIt solves three major problems in app development:

### A. Decoupling (Loose Coupling)
* **Without DI:** Your Bloc creates a Repository directly (`repository = new AuthRepository()`). If you change the repository name or required arguments, you have to break and fix the Bloc code.
* **With DI:** Your Bloc asks for an `AuthRepository`. It doesn't care *how* it's created. You can change the implementation in one place (the injection file) without touching the Bloc.

### B. Testability
* When writing unit tests, you don't want to make real API calls.
* With GetIt, you can easily swap the "Real Repository" with a "Mock Repository" during tests. Your app logic won't know the difference, allowing you to test safely and quickly.

### C. Scope Management (Optimization)
* GetIt handles the lifecycle of your objects.
* It ensures you don't accidentally create 10 copies of your Database Service (which would eat up memory). It ensures you use the *same* instance everywhere.

---

## 3. The 3 Main Registration Methods (Detailed Comparison)

This is the most critical part of using GetIt. Choosing the wrong method can cause memory leaks or stale data.

### Method 1: `registerFactory`

* **What it does:** It creates a **brand new instance** of the class every single time you call `sl<MyClass>()`.
* **Real World Analogy:** A Vending Machine. Every time you buy a soda, you get a *new* bottle. You don't get the same empty bottle someone else just finished.
* **Code:**
    ```dart
    sl.registerFactory(() => AuthBloc(sl()));
    ```
* **When to use:**
    * **Blocs / Cubits / ViewModels:** When a user closes a screen (e.g., Login) and comes back later, you want a fresh state (empty text fields), not the old state from 5 minutes ago.

### Method 2: `registerSingleton`

* **What it does:** It creates the instance **immediately** when the `init()` function runs (at app startup). It keeps this one single instance alive forever.
* **Real World Analogy:** The Engine in your Car. When you start the car (App launch), the engine starts immediately. You only have one engine, and it stays running the whole time.
* **Code:**
    ```dart
    sl.registerSingleton(ConfigService());
    ```
* **When to use:**
    * **Configuration / Logging Services:** Things that *must* be ready before the user sees the first screen.
    * *Warning:* If you register too many Singletons, your app will take a long time to show the splash screen (slow startup).

### Method 3: `registerLazySingleton` (Most Common)

* **What it does:** It keeps one single instance alive (like Singleton), **BUT** it doesn't create it until the **first time you ask for it**.
* **Real World Analogy:** A Spare Tire. It is part of the car, but it sits there doing nothing and taking up no effort until you actually get a flat tire and need to use it.
* **Code:**
    ```dart
    sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
    ```
* **When to use:**
    * **Repositories / Data Sources / API Clients:** You don't need to connect to the database or API the instant the app opens. You only need to connect when the user actually clicks "Login". This makes the app startup faster (Lazy Loading).

| Feature | `registerFactory` | `registerSingleton` | `registerLazySingleton` |
| :--- | :--- | :--- | :--- |
| **Instance Creation** | New every time | Immediate (at startup) | On first request |
| **Memory Usage** | High (if not disposed) | Constant | Efficient (On demand) |
| **Best For** | UI Logic (Blocs) | Core Configs | Data Layers (Repos/APIs) |

---

## 4. How to Use It (Implementation Steps)

### Step A: Installation
Add the package to your `pubspec.yaml`:
```yaml
dependencies:
  get_it: ^7.6.0