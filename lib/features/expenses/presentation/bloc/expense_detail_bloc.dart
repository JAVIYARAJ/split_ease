import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/common/cubit/app_user_cubit.dart';
import 'package:split_ease/features/expenses/domain/usecases/get_expense_detail_usecase.dart';
import 'package:split_ease/features/expenses/domain/usecases/delete_expense_usecase.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_event.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_state.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';

class ExpenseDetailBloc extends Bloc<ExpenseDetailEvent, ExpenseDetailState> {
  /// Logic Coordinator for the Expense Detail Page.
  /// 
  /// Manages fetching detailed information about a single expense, 
  /// including participants, summaries, and deleting the expense.
  final GetExpenseDetailUseCase _getExpenseDetailUseCase;
  final DeleteExpenseUseCase _deleteExpenseUseCase;
  final AppUserCubit _appUserCubit;
  final DataRefreshCubit _dataRefreshCubit;

  ExpenseDetailBloc(this._getExpenseDetailUseCase, this._deleteExpenseUseCase, this._appUserCubit, this._dataRefreshCubit) : super(ExpenseDetailInitial()) {
    on<FetchExpenseDetailEvent>(_onFetchExpenseDetail);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<MarkExpenseAsChanged>(_onMarkExpenseAsChanged);
  }

  void _onMarkExpenseAsChanged(
    MarkExpenseAsChanged event,
    Emitter<ExpenseDetailState> emit,
  ) {
    if (state is ExpenseDetailLoaded) {
      emit((state as ExpenseDetailLoaded).copyWith(hasChanges: true));
    }
  }

  /// Fetches the expense details from the repository. 
  /// Logic Moved from UI: Error handling and loading states are centralized here.
  Future<void> _onFetchExpenseDetail(
    FetchExpenseDetailEvent event,
    Emitter<ExpenseDetailState> emit,
  ) async {
    final bool currentHasChanges = state.hasChanges;
    emit(ExpenseDetailLoading(hasChanges: currentHasChanges));
    final result = await _getExpenseDetailUseCase(event.expenseId);
    
    final appUserState = _appUserCubit.state;
    String currentUserId = "";
    if (appUserState is AppUserLoggedIn) {
      currentUserId = appUserState.user.id;
    }
    
    result.fold(
      (failure) => emit(ExpenseDetailError(failure.message, hasChanges: currentHasChanges)),
      (expenseDetail) => emit(ExpenseDetailLoaded(expenseDetail, currentUserId, hasChanges: currentHasChanges)),
    );
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is ExpenseDetailLoaded) {
      if (currentState.currentUserId != currentState.expenseDetail.createdBy.id) {
        emit(const ExpenseDeleteError("You do not have permission to delete this expense."));
        return;
      }
    }

    emit(ExpenseDeleteLoading());
    final result = await _deleteExpenseUseCase(event.expenseId);
    
      result.fold(
        (failure) => emit(ExpenseDeleteError(failure.message)),
        (_) {
          _dataRefreshCubit.markMultipleForRefresh([
            RefreshType.groups,
            RefreshType.friends,
            RefreshType.activity,
          ]);

          if (currentState is ExpenseDetailLoaded) {
            if (currentState.expenseDetail.group?.id != null) {
              _dataRefreshCubit.markForRefresh(RefreshType.groupDetail, id: currentState.expenseDetail.group!.id);
            }
            // For now mark generic friend details for refresh. 
            // Better: identify the friend from the expense detail splits.
             _dataRefreshCubit.markForRefresh(RefreshType.friendDetail); 
          }
          
          emit(ExpenseDeleted());
        },
      );
    }
}
