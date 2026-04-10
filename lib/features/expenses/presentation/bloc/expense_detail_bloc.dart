import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/common/cubit/app_user_cubit.dart';
import 'package:split_ease/features/expenses/domain/usecases/get_expense_detail_usecase.dart';
import 'package:split_ease/features/expenses/domain/usecases/delete_expense_usecase.dart';
import 'package:split_ease/features/expenses/domain/usecases/restore_expense_usecase.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_event.dart';
import 'package:split_ease/features/expenses/presentation/bloc/expense_detail_state.dart';
import 'package:split_ease/features/expenses/domain/usecases/add_expense_comment_usecase.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';
import 'package:split_ease/features/groups/domain/usecases/get_group_members.dart';

class ExpenseDetailBloc extends Bloc<ExpenseDetailEvent, ExpenseDetailState> {
  /// Logic Coordinator for the Expense Detail Page.
  /// 
  /// Manages fetching detailed information about a single expense, 
  /// including participants, summaries, and deleting/restoring the expense.
  final GetExpenseDetailUseCase _getExpenseDetailUseCase;
  final DeleteExpenseUseCase _deleteExpenseUseCase;
  final RestoreExpenseUseCase _restoreExpenseUseCase;
  final GetGroupMembers _getGroupMembers;
  final AddExpenseCommentUseCase _addExpenseCommentUseCase;
  final AppUserCubit _appUserCubit;
  final DataRefreshCubit _dataRefreshCubit;

  ExpenseDetailBloc(
    this._getExpenseDetailUseCase, 
    this._deleteExpenseUseCase, 
    this._restoreExpenseUseCase,
    this._getGroupMembers, 
    this._addExpenseCommentUseCase, 
    this._appUserCubit, 
    this._dataRefreshCubit
  ) : super(ExpenseDetailInitial()) {
    on<FetchExpenseDetailEvent>(_onFetchExpenseDetail);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<RestoreExpenseEvent>(_onRestoreExpense);
    on<MarkExpenseAsChanged>(_onMarkExpenseAsChanged);
    on<AddExpenseCommentEvent>(_onAddExpenseComment);
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

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => throw Exception("Should not happen"));
      emit(ExpenseDetailError(failure.message, hasChanges: currentHasChanges));
      return;
    }

    final expenseDetail = result.fold((l) => throw Exception("Should not happen"), (r) => r);
    String? role;
    if (expenseDetail.group?.id != null) {
      final membersResult = await _getGroupMembers(expenseDetail.group!.id!);
      membersResult.fold(
        (_) => null,
        (members) {
          final me = members.cast<GroupMemberEntity?>().firstWhere(
            (m) => m?.userId == currentUserId,
            orElse: () => null,
          );
          role = me?.role;
        },
      );
    }
    emit(ExpenseDetailLoaded(expenseDetail, currentUserId, currentUserRole: role, hasChanges: currentHasChanges));
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is ExpenseDetailLoaded) {
      if (!currentState.canManageExpense) {
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
             _dataRefreshCubit.markForRefresh(RefreshType.friendDetail); 
          }
          
          emit(ExpenseDeleted());
        },
      );
    }

  Future<void> _onRestoreExpense(
    RestoreExpenseEvent event,
    Emitter<ExpenseDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is ExpenseDetailLoaded) {
      if (!currentState.canManageExpense) {
        emit(const ExpenseRestoreError("You do not have permission to restore this expense."));
        return;
      }
    }

    emit(ExpenseRestoreLoading());
    final result = await _restoreExpenseUseCase(event.expenseId);
    
    result.fold(
      (failure) => emit(ExpenseRestoreError(failure.message)),
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
           _dataRefreshCubit.markForRefresh(RefreshType.friendDetail); 
        }
        
        emit(ExpenseRestored(event.expenseId));
        // Refresh detail to show it's no longer deleted
        add(FetchExpenseDetailEvent(event.expenseId));
      },
    );
  }

  Future<void> _onAddExpenseComment(
    AddExpenseCommentEvent event,
    Emitter<ExpenseDetailState> emit,
  ) async {
    final result = await _addExpenseCommentUseCase(expenseId: event.expenseId, comment: event.comment);
    result.fold(
      (failure) => null, 
      (_) {
        add(FetchExpenseDetailEvent(event.expenseId));
        add(MarkExpenseAsChanged()); 
      },
    );
  }
}
