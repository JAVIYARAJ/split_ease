import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/recurring_expense_entity.dart';
import '../../domain/usecases/delete_recurring_expense_usecase.dart';
import '../../domain/usecases/get_recurring_expenses_usecase.dart';
import '../../domain/usecases/save_recurring_expense_usecase.dart';
import '../../domain/usecases/toggle_pause_recurring_expense_usecase.dart';
import '../../../../injection_container.dart';
import 'recurring_expenses_event.dart';
import 'recurring_expenses_state.dart';

class RecurringExpensesBloc
    extends Bloc<RecurringExpensesEvent, RecurringExpensesState> {
  final GetRecurringExpensesUseCase _getRecurringExpensesUseCase;
  final SaveRecurringExpenseUseCase _saveRecurringExpenseUseCase;
  final TogglePauseRecurringExpenseUseCase _togglePauseRecurringExpenseUseCase;
  final DeleteRecurringExpenseUseCase _deleteRecurringExpenseUseCase;

  RecurringExpensesBloc({
    GetRecurringExpensesUseCase? getRecurringExpensesUseCase,
    SaveRecurringExpenseUseCase? saveRecurringExpenseUseCase,
    TogglePauseRecurringExpenseUseCase? togglePauseRecurringExpenseUseCase,
    DeleteRecurringExpenseUseCase? deleteRecurringExpenseUseCase,
  })  : _getRecurringExpensesUseCase =
            getRecurringExpensesUseCase ?? sl<GetRecurringExpensesUseCase>(),
        _saveRecurringExpenseUseCase =
            saveRecurringExpenseUseCase ?? sl<SaveRecurringExpenseUseCase>(),
        _togglePauseRecurringExpenseUseCase =
            togglePauseRecurringExpenseUseCase ??
                sl<TogglePauseRecurringExpenseUseCase>(),
        _deleteRecurringExpenseUseCase =
            deleteRecurringExpenseUseCase ?? sl<DeleteRecurringExpenseUseCase>(),
        super(const RecurringExpensesState()) {
    on<LoadRecurringExpensesEvent>(_onLoad);
    on<FilterRecurringExpensesEvent>(_onFilter);
    on<AddRecurringExpenseEvent>(_onAdd);
    on<TogglePauseRecurringExpenseEvent>(_onTogglePause);
    on<DeleteRecurringExpenseEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadRecurringExpensesEvent event,
    Emitter<RecurringExpensesState> emit,
  ) async {
    emit(state.copyWith(status: RecurringExpensesStatus.loading));

    final result = await _getRecurringExpensesUseCase();
    result.fold(
      (failure) {
        // Fallback to loaded state if database empty or offline
        emit(state.copyWith(status: RecurringExpensesStatus.loaded));
      },
      (items) {
        emit(state.copyWith(
          status: RecurringExpensesStatus.loaded,
          items: items,
        ));
      },
    );
  }

  void _onFilter(
    FilterRecurringExpensesEvent event,
    Emitter<RecurringExpensesState> emit,
  ) {
    emit(state.copyWith(selectedFilterIndex: event.filterIndex));
  }

  Future<void> _onAdd(
    AddRecurringExpenseEvent event,
    Emitter<RecurringExpensesState> emit,
  ) async {
    final isEdit = !event.expense.id.startsWith('rec_');
    final result = await _saveRecurringExpenseUseCase(
      event.expense,
      isEdit: isEdit,
    );

    result.fold(
      (failure) {
        // Optimistic UI update fallback
        final updatedList = List<RecurringExpenseEntity>.from(state.items);
        final index = updatedList.indexWhere((e) => e.id == event.expense.id);
        if (index != -1) {
          updatedList[index] = event.expense;
        } else {
          updatedList.insert(0, event.expense);
        }
        emit(state.copyWith(
          status: RecurringExpensesStatus.loaded,
          items: updatedList,
        ));
      },
      (savedId) {
        final savedEntity = event.expense.copyWith(id: savedId);
        final updatedList = List<RecurringExpenseEntity>.from(state.items);
        final index = updatedList.indexWhere((e) => e.id == event.expense.id || e.id == savedId);
        if (index != -1) {
          updatedList[index] = savedEntity;
        } else {
          updatedList.insert(0, savedEntity);
        }
        emit(state.copyWith(
          status: RecurringExpensesStatus.loaded,
          items: updatedList,
        ));
      },
    );
  }

  Future<void> _onTogglePause(
    TogglePauseRecurringExpenseEvent event,
    Emitter<RecurringExpensesState> emit,
  ) async {
    final targetIndex = state.items.indexWhere((item) => item.id == event.id);
    if (targetIndex == -1) return;

    final target = state.items[targetIndex];
    final newPauseState = !target.isPaused;

    // Optimistic state update
    final updatedList = List<RecurringExpenseEntity>.from(state.items);
    updatedList[targetIndex] = target.copyWith(isPaused: newPauseState);
    emit(state.copyWith(items: updatedList));

    final result =
        await _togglePauseRecurringExpenseUseCase(event.id, newPauseState);

    result.fold(
      (failure) {
        // Revert optimistic update on failure
        final revertedList = List<RecurringExpenseEntity>.from(state.items);
        revertedList[targetIndex] = target;
        emit(state.copyWith(
          items: revertedList,
          status: RecurringExpensesStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (_) {
        // Toggle successful via toggle_pause_recurring_expense_rpc
      },
    );
  }

  Future<void> _onDelete(
    DeleteRecurringExpenseEvent event,
    Emitter<RecurringExpensesState> emit,
  ) async {
    final updatedList =
        state.items.where((item) => item.id != event.id).toList();
    emit(state.copyWith(items: updatedList));

    if (!event.id.startsWith('rec_')) {
      await _deleteRecurringExpenseUseCase(event.id);
    }
  }
}
