import 'package:flutter_bloc/flutter_bloc.dart';
export 'package:split_ease/core/enums/app_enums.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:split_ease/features/expenses/domain/usecases/get_expense_metadata_usecase.dart';
import 'package:split_ease/injection_container.dart';
import 'add_edit_recurring_expense_event.dart';
import 'add_edit_recurring_expense_state.dart';

class AddEditRecurringExpenseBloc
    extends Bloc<AddEditRecurringExpenseEvent, AddEditRecurringExpenseState> {
  final GetExpenseMetadataUseCase _getExpenseMetadataUseCase;

  AddEditRecurringExpenseBloc({
    GetExpenseMetadataUseCase? getExpenseMetadataUseCase,
  })  : _getExpenseMetadataUseCase =
            getExpenseMetadataUseCase ?? sl<GetExpenseMetadataUseCase>(),
        super(const AddEditRecurringExpenseState()) {
    on<AddEditRecurringExpenseInitialized>(_onInitialized);
    on<AddEditRecurringExpenseTitleChanged>(_onTitleChanged);
    on<AddEditRecurringExpenseAmountChanged>(_onAmountChanged);
    on<AddEditRecurringExpenseFrequencyChanged>(_onFrequencyChanged);
    on<AddEditRecurringExpenseDueDayChanged>(_onDueDayChanged);
    on<AddEditRecurringExpenseRemindToggled>(_onRemindToggled);
    on<AddEditRecurringExpenseCategoryChanged>(_onCategoryChanged);
  }

  Future<void> _onInitialized(
    AddEditRecurringExpenseInitialized event,
    Emitter<AddEditRecurringExpenseState> emit,
  ) async {
    final existing = event.existing;
    emit(state.copyWith(
      title: existing?.title ?? '',
      amount: existing != null ? existing.amount.toInt().toString() : '',
      frequency: existing?.frequency ?? RecurrenceFrequency.monthly,
      dueDay: existing?.dueDay ?? 1,
      autoRemind: existing?.autoRemind ?? true,
      isLoadingCategories: true,
    ));

    final result = await _getExpenseMetadataUseCase();
    result.fold(
      (failure) {
        emit(state.copyWith(isLoadingCategories: false));
      },
      (metadata) {
        ExpenseCategoryEntity? matched;
        if (existing != null) {
          try {
            matched = metadata.categories.firstWhere(
              (c) =>
                  c.id == existing.categoryId ||
                  c.name.toLowerCase() == existing.categoryName.toLowerCase(),
            );
          } catch (_) {
            matched = metadata.categories.isNotEmpty
                ? metadata.categories.first
                : null;
          }
        } else if (metadata.categories.isNotEmpty) {
          matched = metadata.categories.first;
        }

        emit(state.copyWith(
          categories: metadata.categories,
          selectedCategory: matched,
          isLoadingCategories: false,
        ));
      },
    );
  }

  void _onTitleChanged(
    AddEditRecurringExpenseTitleChanged event,
    Emitter<AddEditRecurringExpenseState> emit,
  ) {
    emit(state.copyWith(title: event.title));
  }

  void _onAmountChanged(
    AddEditRecurringExpenseAmountChanged event,
    Emitter<AddEditRecurringExpenseState> emit,
  ) {
    emit(state.copyWith(amount: event.amount));
  }

  void _onFrequencyChanged(
    AddEditRecurringExpenseFrequencyChanged event,
    Emitter<AddEditRecurringExpenseState> emit,
  ) {
    emit(state.copyWith(frequency: event.frequency));
  }

  void _onDueDayChanged(
    AddEditRecurringExpenseDueDayChanged event,
    Emitter<AddEditRecurringExpenseState> emit,
  ) {
    emit(state.copyWith(dueDay: event.dueDay));
  }

  void _onRemindToggled(
    AddEditRecurringExpenseRemindToggled event,
    Emitter<AddEditRecurringExpenseState> emit,
  ) {
    emit(state.copyWith(autoRemind: event.remind));
  }

  void _onCategoryChanged(
    AddEditRecurringExpenseCategoryChanged event,
    Emitter<AddEditRecurringExpenseState> emit,
  ) {
    emit(state.copyWith(selectedCategory: event.category));
  }
}
