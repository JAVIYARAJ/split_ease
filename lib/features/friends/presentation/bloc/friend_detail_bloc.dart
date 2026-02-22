import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/friends/domain/usecases/get_friend_expense_history_usecase.dart';
import 'package:split_ease/features/friends/presentation/bloc/friend_detail_event.dart';
import 'package:split_ease/features/friends/presentation/bloc/friend_detail_state.dart';

class FriendDetailBloc extends Bloc<FriendDetailEvent, FriendDetailState> {
  final GetFriendExpenseHistoryUseCase _getFriendExpenseHistoryUseCase;

  FriendDetailBloc({
    required GetFriendExpenseHistoryUseCase getFriendExpenseHistoryUseCase,
  })  : _getFriendExpenseHistoryUseCase = getFriendExpenseHistoryUseCase,
        super(const FriendDetailState()) {
    on<LoadFriendDetails>(_onLoadFriendDetails);
    on<LoadFriendExpenseHistory>(_onLoadFriendExpenseHistory);
  }

  void _onLoadFriendDetails(LoadFriendDetails event, Emitter<FriendDetailState> emit) {
    emit(state.copyWith(
      friendEntity: event.friend,
      hasChanges: event.hasChanges,
    ));
    if (event.friend.id.isNotEmpty) {
      add(LoadFriendExpenseHistory(friendId: event.friend.id));
    }
  }

  Future<void> _onLoadFriendExpenseHistory(LoadFriendExpenseHistory event, Emitter<FriendDetailState> emit) async {
    final targetFriendId = event.friendId ?? state.friendEntity?.id;
    if (targetFriendId == null || targetFriendId.isEmpty) return;

    emit(state.copyWith(expenseStatus: FriendDetailExpenseStatus.loading));

    final result = await _getFriendExpenseHistoryUseCase.call(
      GetFriendExpenseHistoryParams(friendId: targetFriendId),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          expenseStatus: FriendDetailExpenseStatus.failure,
          expenseErrorMessage: failure.message,
        ));
      },
      (history) {
        emit(state.copyWith(
          expenseStatus: FriendDetailExpenseStatus.success,
          expenseHistory: history,
        ));
      },
    );
  }
}
