import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import '../../domain/entities/expense_entity.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc() : super(const ExpenseState()) {
    on<ExpenseInitialized>(_onInitialized);
    on<AmountChanged>(_onAmountChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<PayerChanged>(_onPayerChanged);
    on<DateChanged>(_onDateChanged);
    on<SplitTypeChanged>(_onSplitTypeChanged);
    on<SplitOptionChanged>(_onSplitOptionChanged);
    on<AddExpenseSubmitted>(_onAddExpenseSubmitted);
  }



  void _onInitialized(ExpenseInitialized event, Emitter<ExpenseState> emit) {
    // Reset state with the new group
    emit(ExpenseState(group: event.group));
  }

  void _onAmountChanged(AmountChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(amount: event.amount));
  }

  void _onDescriptionChanged(DescriptionChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(description: event.description));
  }

  void _onPayerChanged(PayerChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(payerId: event.userId));
  }

  void _onDateChanged(DateChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(date: event.date));
  }

  void _onSplitTypeChanged(SplitTypeChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(splitType: event.splitType));
  }
  
  void _onSplitOptionChanged(SplitOptionChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(splits: event.splits));
  }

  Future<void> _onAddExpenseSubmitted(AddExpenseSubmitted event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    try {
      // TODO: Implement actual expense submission to backend/usecase
      // final expense = ExpenseEntity(...)
      // await addExpenseUseCase(expense);
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      emit(state.copyWith(status: ExpenseStatus.success));
    } catch (e) {
      emit(state.copyWith(status: ExpenseStatus.failure, errorMessage: e.toString()));
    }
  }
}
