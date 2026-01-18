# Flutter Clean Architecture Guide

This document outlines the architecture used in this project, based on **Uncle Bob's Clean Architecture**. It ensures scalability, testability, and maintainability.

---

## 🏗 High-Level Overview

We strictly follow the **Dependency Rule**:
> **Dependencies only point INWARD.**
> Presentation depends on Domain. Data depends on Domain. Domain depends on nothing.

### The 3 Layers

1.  **Domain (The Core)**
    * **Role:** Business logic and enterprise rules.
    * **Dependencies:** None (Pure Dart).
    * **Contents:** Entities, Usecases, Repository Interfaces.

2.  **Data (The Repository Implementation)**
    * **Role:** Retrieving data from remote or local sources.
    * **Dependencies:** Domain, Third-party libraries (Dio, Hive, etc.).
    * **Contents:** Models, DataSources, Repository Implementations.

3.  **Presentation (The UI)**
    * **Role:** Rendering UI and handling state.
    * **Dependencies:** Domain.
    * **Contents:** BLoC/Providers, Pages, Widgets.

---

## 📂 Folder Structure

```text
lib/
├── core/                   # Global utilities used across features
│   ├── error/              # Failures and Exceptions
│   ├── usecases/           # Base UseCase class
│   └── network/            # Network info/connectivity
├── features/               # Feature-based separation
│   ├── [feature_name]/     # e.g., authentication
│   │   ├── data/
│   │   │   ├── datasources/   # Remote and Local data sources
│   │   │   ├── models/        # DTOs (Data Transfer Objects) with JSON parsing
│   │   │   └── repositories/  # Implementation of Domain repositories
│   │   ├── domain/
│   │   │   ├── entities/      # Plain Dart objects
│   │   │   ├── repositories/  # Abstract classes (contracts)
│   │   │   └── usecases/      # Business logic classes
│   │   └── presentation/
│   │       ├── bloc/          # State Management
│   │       ├── pages/         # Screens
│   │       └── widgets/       # Reusable UI components
└── main.dart