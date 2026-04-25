---
name: add-usecase
description: Add a new operation (usecase) to an existing feature in lib/features/<feature>/. Threads the call end-to-end — datasource RPC → repo method → usecase → bloc event/state → DI. Use when the user asks to "add a usecase", "wire up a new RPC", "add an operation to <feature>", or "let users do X in <feature>".
---

# Add a usecase to an existing feature

Use this when the feature already exists and you need to add one more operation. If the feature doesn't exist yet, use `scaffold-feature` instead.

## Inputs to gather first

- **Target feature folder** under `lib/features/` (e.g. `expenses`, `groups`).
- **Operation name** in `camelCase` (e.g. `restoreExpense`, `markAllRead`).
- **Return type** — `void`, a single entity, a `List<Entity>`, or a primitive.
- **Params** — none, a single primitive (`String groupId`), or a multi-field params class.
- **Supabase RPC name + arg names** (the `p_*` keys the RPC expects).
- **Whether the existing bloc handles this** or a new bloc/cubit is needed. If existing — which event/state names to add.

If the params shape is unclear, look at sibling usecases in the same feature for the convention (`*_params.dart` with `Equatable` + `toJson()` is standard for >1 field).

## The 5 places to touch

In dependency order — do not skip any:

1. **Data source** (`data/datasources/<feature>_remote_data_source.dart`) — add abstract method + impl.
2. **Repository** (`domain/repositories/<feature>_repository.dart` + `data/repositories/<feature>_repository_impl.dart`) — add interface method + impl.
3. **Usecase** (`domain/usecases/<operation>_usecase.dart`) — new file.
4. **(Optional) Params** (`domain/usecases/<operation>_params.dart`) — new file if multi-field.
5. **DI** (`lib/injection_container.dart`) — register usecase, update bloc factory if bloc gains a new dependency.
6. **Bloc** (`presentation/bloc/<feature>_bloc.dart` + `_event.dart` + `_state.dart`) — add event + handler + states.

## 1. Data source

Add to the abstract interface, then to the impl. Wrap in `try/catch` and throw `ServerException`.

```dart
// abstract interface class
Future<void> restoreExpense(String expenseId);

// impl
@override
Future<void> restoreExpense(String expenseId) async {
  try {
    await client.rpc('restore_expense_rpc', params: {'p_expense_id': expenseId});
  } catch (error) {
    throw ServerException(message: ErrorMessageUtils.generate(error));
  }
}
```

For RPCs returning a single row use `.single()`; for lists, cast `response as List` and map. Mirror existing usages in `lib/features/activity/data/datasources/activity_remote_data_source.dart` or `lib/features/expenses/data/datasources/expense_remote_data_source.dart`.

## 2. Repository

Interface — add method returning `Either<Failure, T>`:

```dart
Future<Either<Failure, void>> restoreExpense(String expenseId);
```

Impl — wrap data source call in `try` / `on ServerException` / `catch`:

```dart
@override
Future<Either<Failure, void>> restoreExpense(String expenseId) async {
  try {
    await remoteDataSource.restoreExpense(expenseId);
    return const Right(null);
  } on ServerException catch (e) {
    return Left(Failure(message: e.message));
  } catch (e) {
    return Left(Failure(message: e.toString()));
  }
}
```

## 3. Usecase

File: `domain/usecases/<operation>_usecase.dart`. Implements `UseCase<SuccessType, Params>`. Class name is `PascalCase` of the operation, optionally suffixed `UseCase` (the codebase mixes both — match the feature's existing style: `expenses/` uses `UseCase`, `groups/` mostly omits it).

Single primitive param:
```dart
class RestoreExpenseUseCase implements UseCase<void, String> {
  final ExpenseRepository repository;
  RestoreExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.restoreExpense(params);
  }
}
```

No params — use `NoParams` from `core/usecases/use_case.dart`.

Multi-field — create `<operation>_params.dart` with an `Equatable` class. Mirror `lib/features/expenses/domain/usecases/create_expense_params.dart`:

```dart
import 'package:equatable/equatable.dart';

class RestoreExpenseParams extends Equatable {
  final String expenseId;
  final String? note;

  const RestoreExpenseParams({required this.expenseId, this.note});

  Map<String, dynamic> toJson() => {
    'p_expense_id': expenseId,
    'p_note': note,
  };

  @override
  List<Object?> get props => [expenseId, note];
}
```

Note: `toJson()` keys use the Supabase `p_*` convention so the data source can pass `params.toJson()` straight to `client.rpc(..., params: ...)`.

## 4. DI registration

Open `lib/injection_container.dart`, find the `_<feature>()` block, and add:

```dart
sl.registerLazySingleton(() => RestoreExpenseUseCase(sl()));
```

If the bloc gains a new constructor argument, **update the bloc's `registerFactory(...)`** in the same file to pass `sl<RestoreExpenseUseCase>()`. Forgetting this is the #1 cause of runtime errors after adding a usecase.

## 5. Bloc — event, state, handler

Add an event class to `<feature>_event.dart`:

```dart
class RestoreExpenseRequested extends <Feature>Event {
  final String expenseId;
  RestoreExpenseRequested(this.expenseId);
}
```

Add success/failure states (or reuse the existing `Loaded` / `Error` states if appropriate) in `<feature>_state.dart`:

```dart
class ExpenseRestoreSuccess extends <Feature>State {}
class ExpenseRestoreFailure extends <Feature>State {
  final String message;
  ExpenseRestoreFailure(this.message);
}
```

In the bloc constructor, add the dependency and register the handler:

```dart
final RestoreExpenseUseCase restoreExpenseUseCase;

<Feature>Bloc({
  ...,
  required this.restoreExpenseUseCase,
}) : super(...) {
  ...
  on<RestoreExpenseRequested>(_onRestoreExpense);
}

Future<void> _onRestoreExpense(
  RestoreExpenseRequested event,
  Emitter<<Feature>State> emit,
) async {
  emit(<Feature>Loading());
  final result = await restoreExpenseUseCase(event.expenseId);
  result.fold(
    (failure) => emit(ExpenseRestoreFailure(failure.message)),
    (_) => emit(ExpenseRestoreSuccess()),
  );
}
```

If the operation should refresh shared lists across the app (expense list, activity feed, etc.), call `dataRefreshCubit.triggerRefresh(...)` after success — the codebase uses `DataRefreshCubit` from `core/services/data_refresh_service.dart` for this.

## Verification

- [ ] `flutter analyze` passes.
- [ ] Data source method throws `ServerException`, never returns `Either`.
- [ ] Repository impl converts exceptions to `Failure`, not strings.
- [ ] Usecase is registered in `_<feature>()` in `injection_container.dart`.
- [ ] If the bloc gained a constructor arg, `registerFactory(() => <Feature>Bloc(...))` was updated.
- [ ] UI dispatches the new event somewhere (otherwise the wiring is dead code).
