import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/usecases/get_group_detail.dart';
import '../../domain/usecases/delete_group.dart';
import 'package:split_ease/features/auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/group_member_balance_entity.dart';
import '../../domain/usecases/get_group_expense_history.dart';
import '../../domain/usecases/leave_group.dart';
import '../../domain/usecases/remove_group_member.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';

import '../../domain/usecases/update_member_role.dart';


part 'group_settings_event.dart';
part 'group_settings_state.dart';

class GroupSettingsBloc extends Bloc<GroupSettingsEvent, GroupSettingsState> {
  final GetGroupDetail getGroupDetail;
  final DeleteGroup deleteGroup;
  final AuthRepository authRepository;
  final GetGroupExpenseHistory getGroupExpenseHistory;
  final LeaveGroup leaveGroup;
  final RemoveGroupMember removeGroupMember;
  final UpdateMemberRole updateMemberRole;
  final DataRefreshCubit dataRefreshCubit;

  GroupSettingsBloc({
    required this.getGroupDetail,
    required this.deleteGroup,
    required this.authRepository,
    required this.getGroupExpenseHistory,
    required this.leaveGroup,
    required this.removeGroupMember,
    required this.updateMemberRole,
    required this.dataRefreshCubit,
  }) : super(GroupSettingsInitial()) {
    on<LoadGroupSettings>(_onLoadGroupSettings);
    on<LeaveGroupEvent>(_onLeaveGroup);
    on<DeleteGroupEvent>(_onDeleteGroup);
    on<RemoveMemberEvent>(_onRemoveMember);
    on<UpdateMemberRoleEvent>(_onUpdateMemberRole);
  }

  void _onLoadGroupSettings(LoadGroupSettings event, Emitter<GroupSettingsState> emit) async {
    emit(GroupSettingsLoading());

    final groupFuture = getGroupDetail(GroupDetailParam(event.groupId));
    final userFuture = authRepository.getCurrentUser();
    final historyFuture = getGroupExpenseHistory(GroupExpenseHistoryParam(event.groupId));

    final result = await groupFuture;
    final userResult = await userFuture;
    final historyResult = await historyFuture;

    String? currentUserId;
    userResult.fold((l) => null, (user) => currentUserId = user.id);

    List<GroupMemberBalanceEntity>? memberBalances;
    double? overallBalance;
    bool? youAreOwed;

    historyResult.fold(
      (l) => null,
      (history) {
        memberBalances = history.memberBalances;
        overallBalance = history.overallBalance;
        youAreOwed = history.youAreOwed;
      },
    );

    result.fold(
      (failure) => emit(GroupSettingsError(
        failure.message,
        overallBalance: overallBalance,
        youAreOwed: youAreOwed,
      )),
      (group) => emit(GroupSettingsLoaded(
        group,
        hasChanges: event.hasChanges,
        currentUserId: currentUserId,
        memberBalances: memberBalances,
        overallBalance: overallBalance,
        youAreOwed: youAreOwed,
      )),
    );
  }

  void _onLeaveGroup(LeaveGroupEvent event, Emitter<GroupSettingsState> emit) async {
     final data = _getCurrentStateData();

     emit(GroupSettingsLoading(
       group: data.group,
       currentUserId: data.currentUserId,
       memberBalances: data.memberBalances,
       overallBalance: data.overallBalance,
       youAreOwed: data.youAreOwed,
     ));

     final result = await leaveGroup(event.groupId);
     result.fold(
       (failure) => emit(GroupSettingsError(
         failure.message,
         group: data.group,
         currentUserId: data.currentUserId,
         memberBalances: data.memberBalances,
         overallBalance: data.overallBalance,
         youAreOwed: data.youAreOwed,
       )),
       (success) {
         dataRefreshCubit.markMultipleForRefresh([RefreshType.groups, RefreshType.activity]);
         emit(GroupActionSuccess("Left group successfully"));
       },
     );
  }

  void _onRemoveMember(RemoveMemberEvent event, Emitter<GroupSettingsState> emit) async {
     final data = _getCurrentStateData();

     emit(GroupSettingsLoading(
       group: data.group,
       currentUserId: data.currentUserId,
       memberBalances: data.memberBalances,
       overallBalance: data.overallBalance,
       youAreOwed: data.youAreOwed,
     ));

     final result = await removeGroupMember(RemoveGroupMemberParams(groupId: event.groupId, userId: event.userId));
     result.fold(
       (failure) => emit(GroupSettingsError(
         failure.message,
         group: data.group,
         currentUserId: data.currentUserId,
         memberBalances: data.memberBalances,
         overallBalance: data.overallBalance,
         youAreOwed: data.youAreOwed,
       )),
       (success) {
         dataRefreshCubit.markMultipleForRefresh([RefreshType.groups, RefreshType.activity]);
         add(LoadGroupSettings(event.groupId, hasChanges: true));
         emit(GroupActionSuccess("Member removed successfully", shouldPop: false));
       },
     );
  }

  void _onUpdateMemberRole(UpdateMemberRoleEvent event, Emitter<GroupSettingsState> emit) async {
     final data = _getCurrentStateData();

     emit(GroupSettingsLoading(
       group: data.group,
       currentUserId: data.currentUserId,
       memberBalances: data.memberBalances,
       overallBalance: data.overallBalance,
       youAreOwed: data.youAreOwed,
     ));

     final result = await updateMemberRole(UpdateMemberRoleParams(
       groupId: event.groupId,
       userId: event.userId,
       newRole: event.newRole,
     ));

     result.fold(
       (failure) => emit(GroupSettingsError(
         failure.message,
         group: data.group,
         currentUserId: data.currentUserId,
         memberBalances: data.memberBalances,
         overallBalance: data.overallBalance,
         youAreOwed: data.youAreOwed,
       )),
       (success) {
         dataRefreshCubit.markMultipleForRefresh([RefreshType.groups, RefreshType.activity]);
         add(LoadGroupSettings(event.groupId, hasChanges: true));
         emit(GroupActionSuccess("Member role updated successfully", shouldPop: false));
       },
     );
  }

  void _onDeleteGroup(DeleteGroupEvent event, Emitter<GroupSettingsState> emit) async {
     final data = _getCurrentStateData();

     emit(GroupSettingsLoading(
       group: data.group,
       currentUserId: data.currentUserId,
       memberBalances: data.memberBalances,
       overallBalance: data.overallBalance,
       youAreOwed: data.youAreOwed,
     ));

     final result = await deleteGroup(event.groupId);
     result.fold(
       (failure) => emit(GroupSettingsError(
         failure.message,
         group: data.group,
         currentUserId: data.currentUserId,
         memberBalances: data.memberBalances,
         overallBalance: data.overallBalance,
         youAreOwed: data.youAreOwed,
       )),
       (success) {
         dataRefreshCubit.markMultipleForRefresh([RefreshType.groups, RefreshType.activity]);
         emit(GroupActionSuccess("Deleted group successfully"));
       },
     );
  }

  _GroupStateData _getCurrentStateData() {
    if (state is GroupSettingsLoaded) {
      final s = state as GroupSettingsLoaded;
      return _GroupStateData(s.group, s.currentUserId, s.memberBalances, s.overallBalance, s.youAreOwed);
    } else if (state is GroupSettingsLoading) {
      final s = state as GroupSettingsLoading;
      return _GroupStateData(s.group, s.currentUserId, s.memberBalances, s.overallBalance, s.youAreOwed);
    } else if (state is GroupSettingsError) {
      final s = state as GroupSettingsError;
      return _GroupStateData(s.group, s.currentUserId, s.memberBalances, s.overallBalance, s.youAreOwed);
    }
    return _GroupStateData(null, null, null, null, null);
  }
}

class _GroupStateData {
  final GroupEntity? group;
  final String? currentUserId;
  final List<GroupMemberBalanceEntity>? memberBalances;
  final double? overallBalance;
  final bool? youAreOwed;

  _GroupStateData(this.group, this.currentUserId, this.memberBalances, this.overallBalance, this.youAreOwed);
}
