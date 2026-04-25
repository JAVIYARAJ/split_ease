---
name: scaffold-feature
description: Scaffold a new Clean Architecture feature folder under lib/features/<name>/ with data/domain/presentation layers (datasource, model, entity, repo + impl, usecase, bloc/event/state, page) wired through GetIt. Use when the user asks to "create a new feature", "add a feature module", or "scaffold <X> feature".
---

# Scaffold a new feature (Clean Architecture)

This project follows strict Clean Architecture (`CLEAN_ARCHITECTURE_GUIDE.md`) and uses GetIt for DI (`DEPENDENCY_INJECTION.md`). All Supabase calls go through a remote data source; repositories return `Either<Failure, T>` from `fpdart`.

## Inputs to gather first

Before scaffolding, confirm with the user:
- **Feature name** in `snake_case` (e.g. `notifications`) — used for folder + file prefixes.
- **Primary entity name** in `PascalCase` (e.g. `Notification`) — used for class names.
- **First operation** (usecase) — name + return type + whether it takes params (e.g. `getNotifications` → `List<NotificationEntity>`, `NoParams`).
- **Supabase RPC name** (or table query) the data source will call.

If any are unclear, ask before generating.

## Folder layout to create

```
lib/features/<feature>/
├── data/
│   ├── datasources/<feature>_remote_data_source.dart
│   ├── models/<entity>_model.dart
│   └── repositories/<feature>_repository_impl.dart
├── domain/
│   ├── entities/<entity>_entity.dart
│   ├── repositories/<feature>_repository.dart
│   └── usecases/<operation>_usecase.dart
└── presentation/
    ├── bloc/<feature>_bloc.dart
    ├── bloc/<feature>_event.dart
    ├── bloc/<feature>_state.dart
    └── pages/<feature>_page.dart
```

## Templates

Replace `<feature>` (snake_case), `<Feature>` (PascalCase), `<Entity>` (PascalCase singular). Reference: `lib/features/activity/` is the cleanest existing example to mirror.

### 1. Entity (`domain/entities/<entity>_entity.dart`)

Plain Dart, no JSON, no dependencies. Fields are `final`; constructor is `const` when possible.

```dart
class <Entity>Entity {
  final String id;
  final String name;
  final DateTime createdAt;

  const <Entity>Entity({
    required this.id,
    required this.name,
    required this.createdAt,
  });
}
```

### 2. Model (`data/models/<entity>_model.dart`)

Extends entity, adds `fromJson` (and `toJson` only if writes are needed). JSON keys are `snake_case` (Supabase convention). Use defensive parsing for nullable / numeric fields like `lib/features/activity/data/models/activity_model.dart` does.

```dart
import '../../domain/entities/<entity>_entity.dart';

class <Entity>Model extends <Entity>Entity {
  const <Entity>Model({
    required super.id,
    required super.name,
    required super.createdAt,
  });

  factory <Entity>Model.fromJson(Map<String, dynamic> json) {
    return <Entity>Model(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])?.toLocal() ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
```

### 3. Remote data source (`data/datasources/<feature>_remote_data_source.dart`)

`abstract interface class` + impl. Wrap every Supabase call in `try/catch` and rethrow as `ServerException(message: ErrorMessageUtils.generate(error))`. Never return `Either` from a data source — that's the repo's job.

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/utils/error_message_utils.dart';
import '../models/<entity>_model.dart';

abstract interface class <Feature>RemoteDataSource {
  Future<List<<Entity>Model>> get<Feature>();
}

class <Feature>RemoteDataSourceImpl implements <Feature>RemoteDataSource {
  final SupabaseClient client;

  <Feature>RemoteDataSourceImpl({required this.client});

  @override
  Future<List<<Entity>Model>> get<Feature>() async {
    try {
      final response = await client.rpc('<rpc_name>');
      return (response as List).map((e) => <Entity>Model.fromJson(e)).toList();
    } catch (error) {
      throw ServerException(message: ErrorMessageUtils.generate(error));
    }
  }
}
```

### 4. Repository contract (`domain/repositories/<feature>_repository.dart`)

```dart
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/<entity>_entity.dart';

abstract interface class <Feature>Repository {
  Future<Either<Failure, List<<Entity>Entity>>> get<Feature>();
}
```

### 5. Repository impl (`data/repositories/<feature>_repository_impl.dart`)

Catches `ServerException` first, generic `catch` second. Returns `Right(data)` on success.

```dart
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/<entity>_entity.dart';
import '../../domain/repositories/<feature>_repository.dart';
import '../datasources/<feature>_remote_data_source.dart';

class <Feature>RepositoryImpl implements <Feature>Repository {
  final <Feature>RemoteDataSource remoteDataSource;

  <Feature>RepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<<Entity>Entity>>> get<Feature>() async {
    try {
      final result = await remoteDataSource.get<Feature>();
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
```

### 6. Usecase (`domain/usecases/<operation>_usecase.dart`)

Implements `UseCase<SuccessType, Params>` from `core/usecases/use_case.dart`. Use `NoParams` if there's no input. For multi-field input, create a sibling `<operation>_params.dart` extending `Equatable` (mirror `lib/features/expenses/domain/usecases/create_expense_params.dart`).

```dart
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/<entity>_entity.dart';
import '../repositories/<feature>_repository.dart';

class Get<Feature>UseCase implements UseCase<List<<Entity>Entity>, NoParams> {
  final <Feature>Repository repository;

  Get<Feature>UseCase(this.repository);

  @override
  Future<Either<Failure, List<<Entity>Entity>>> call(NoParams params) async {
    return await repository.get<Feature>();
  }
}
```

### 7. Bloc + event + state (`presentation/bloc/`)

This project uses `part`/`part of` for event and state files (not separate imports). State + event are `sealed` and `@immutable`. The handler emits Loading → calls usecase → `.fold` to Error/Loaded.

`<feature>_bloc.dart`:
```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/use_case.dart';
import '../../domain/entities/<entity>_entity.dart';
import '../../domain/usecases/get_<feature>_usecase.dart';

part '<feature>_event.dart';
part '<feature>_state.dart';

class <Feature>Bloc extends Bloc<<Feature>Event, <Feature>State> {
  final Get<Feature>UseCase get<Feature>UseCase;

  <Feature>Bloc({required this.get<Feature>UseCase}) : super(<Feature>Initial()) {
    on<Load<Feature>>(_onLoad);
  }

  Future<void> _onLoad(Load<Feature> event, Emitter<<Feature>State> emit) async {
    emit(<Feature>Loading());
    final result = await get<Feature>UseCase(NoParams());
    result.fold(
      (failure) => emit(<Feature>Error(failure.message)),
      (data) => emit(<Feature>Loaded(data)),
    );
  }
}
```

`<feature>_event.dart`:
```dart
part of '<feature>_bloc.dart';

@immutable
sealed class <Feature>Event {}

class Load<Feature> extends <Feature>Event {}
```

`<feature>_state.dart`:
```dart
part of '<feature>_bloc.dart';

@immutable
sealed class <Feature>State {}

class <Feature>Initial extends <Feature>State {}
class <Feature>Loading extends <Feature>State {}

class <Feature>Loaded extends <Feature>State {
  final List<<Entity>Entity> items;
  <Feature>Loaded(this.items);
}

class <Feature>Error extends <Feature>State {
  final String message;
  <Feature>Error(this.message);
}
```

### 8. Page (`presentation/pages/<feature>_page.dart`)

Provide the bloc via `BlocProvider` pulling from `sl<>`. Dispatch `Load<Feature>` in `initState` (or via `..add(...)` on creation). Render `BlocBuilder` switching on the sealed state.

## DI registration (mandatory final step)

Open `lib/injection_container.dart` and:

1. Add a new private function `void _<feature>() { ... }` near the other feature blocks.
2. Call it from `_features()`.
3. Register in this order — **data source → repo → usecase → bloc**:

```dart
void _<feature>() {
  sl.registerLazySingleton<<Feature>RemoteDataSource>(
    () => <Feature>RemoteDataSourceImpl(client: sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<<Feature>Repository>(
    () => <Feature>RepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => Get<Feature>UseCase(sl()));
  sl.registerFactory(() => <Feature>Bloc(get<Feature>UseCase: sl()));
}
```

Use `registerLazySingleton` for data sources / repos / usecases and `registerFactory` for blocs/cubits. See the `register-di` skill for full rules and the rationale.

## Verification checklist

After scaffolding, verify:
- [ ] `flutter analyze` passes (no missing imports, no unused vars).
- [ ] All eight files exist and import correctly.
- [ ] DI block is wired into `_features()`.
- [ ] Repository implements the **interface** from domain (not the impl class).
- [ ] Data source throws `ServerException`, repo converts to `Failure`.
- [ ] Bloc factory in DI matches the bloc's constructor parameters (named, in same order doesn't matter — names do).
- [ ] No reference to a route/page in `lib/core/routing/` is missing if the page should be navigable.
