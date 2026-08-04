import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_expense_history_entity.dart';
import 'package:split_ease/features/groups/domain/usecases/get_group_detail.dart';
import 'package:split_ease/features/groups/domain/usecases/get_group_expense_history.dart';
import 'package:split_ease/core/enums/app_enums.dart';
export 'package:split_ease/core/enums/app_enums.dart';

part 'group_detail_event.dart';

part 'group_detail_state.dart';

class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  final GetGroupDetail getGroupDetail;
  final GetGroupExpenseHistory getGroupExpenseHistory;

  GroupDetailBloc({
    required this.getGroupDetail,
    required this.getGroupExpenseHistory,
  }) : super(const GroupDetailState()) {
    on<LoadGroupDetails>(_onLoadGroupDetails);
    on<LoadGroupExpenseHistory>(_onLoadGroupExpenseHistory);
  }

  Future<void> _onLoadGroupDetails(LoadGroupDetails event, Emitter<GroupDetailState> emit) async {
    emit(state.copyWith(status: GroupDetailStatus.loading, hasChanges: event.hasChanges || state.hasChanges));
    try {
      final id = event.groupId ?? state.groupEntity?.id;
      var response = await getGroupDetail(GroupDetailParam(id));
      response.fold(
        (l) {
          emit(state.copyWith(status: GroupDetailStatus.failure, errorMessage: l.message));
        },
        (r) {
          emit(state.copyWith(status: GroupDetailStatus.success, groupEntity: r, hasChanges: event.hasChanges || state.hasChanges));
        },
      );
    } catch (e) {
      emit(state.copyWith(status: GroupDetailStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadGroupExpenseHistory(LoadGroupExpenseHistory event, Emitter<GroupDetailState> emit) async {
    emit(state.copyWith(expenseStatus: GroupDetailExpenseStatus.loading));
    try {
      final String? groupId = state.groupEntity?.id ?? event.groupId;
      final response = await getGroupExpenseHistory(GroupExpenseHistoryParam(groupId));
      response.fold(
        (l) {
          emit(state.copyWith(
            expenseStatus: GroupDetailExpenseStatus.failure,
            expenseErrorMessage: l.message,
          ));
        },
        (r) {
          emit(state.copyWith(
            expenseStatus: GroupDetailExpenseStatus.success,
            expenseHistory: r,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        expenseStatus: GroupDetailExpenseStatus.failure,
        expenseErrorMessage: e.toString(),
      ));
    }
  }
}
