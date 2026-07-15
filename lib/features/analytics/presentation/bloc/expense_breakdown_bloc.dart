import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import '../../domain/usecases/get_expense_breakdown.dart';
import 'expense_breakdown_event.dart';
import 'expense_breakdown_state.dart';

class ExpenseBreakdownBloc extends Bloc<ExpenseBreakdownEvent, ExpenseBreakdownState> {
  final GetExpenseBreakdown getExpenseBreakdown;

  ExpenseBreakdownBloc({required this.getExpenseBreakdown}) : super(const ExpenseBreakdownState()) {
    on<LoadExpenseBreakdown>(_onLoadExpenseBreakdown);
  }

  Future<void> _onLoadExpenseBreakdown(
    LoadExpenseBreakdown event,
    Emitter<ExpenseBreakdownState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseBreakdownStatus.loading));
    final result = await getExpenseBreakdown(NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: ExpenseBreakdownStatus.failure,
        errorMessage: failure.message,
      )),
      (breakdown) => emit(state.copyWith(
        status: ExpenseBreakdownStatus.success,
        breakdown: breakdown,
      )),
    );
  }
}
