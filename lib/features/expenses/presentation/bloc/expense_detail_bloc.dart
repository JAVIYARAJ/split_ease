import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/expenses/domain/usecases/get_expense_detail_usecase.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_event.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_state.dart';

class ExpenseDetailBloc extends Bloc<ExpenseDetailEvent, ExpenseDetailState> {
  final GetExpenseDetailUseCase _getExpenseDetailUseCase;

  ExpenseDetailBloc(this._getExpenseDetailUseCase) : super(ExpenseDetailInitial()) {
    on<FetchExpenseDetailEvent>(_onFetchExpenseDetail);
  }

  Future<void> _onFetchExpenseDetail(
    FetchExpenseDetailEvent event,
    Emitter<ExpenseDetailState> emit,
  ) async {
    emit(ExpenseDetailLoading());
    final result = await _getExpenseDetailUseCase(event.expenseId);
    
    result.fold(
      (failure) => emit(ExpenseDetailError(failure.message)),
      (expenseDetail) => emit(ExpenseDetailLoaded(expenseDetail)),
    );
  }
}
