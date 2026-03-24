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


part 'group_settings_event.dart';
part 'group_settings_state.dart';

class GroupSettingsBloc extends Bloc<GroupSettingsEvent, GroupSettingsState> {
  final GetGroupDetail getGroupDetail;
  final DeleteGroup deleteGroup;
  final AuthRepository authRepository;
  final GetGroupExpenseHistory getGroupExpenseHistory;
  final LeaveGroup leaveGroup;
  final RemoveGroupMember removeGroupMember;
  final DataRefreshCubit dataRefreshCubit;

  GroupSettingsBloc({
    required this.getGroupDetail,
    required this.deleteGroup,
    required this.authRepository,
    required this.getGroupExpenseHistory,
    required this.leaveGroup,
    required this.removeGroupMember,
    required this.dataRefreshCubit,
  }) : super(GroupSettingsInitial()) {
    on<LoadGroupSettings>(_onLoadGroupSettings);
    on<LeaveGroupEvent>(_onLeaveGroup);
    on<DeleteGroupEvent>(_onDeleteGroup);
    on<RemoveMemberEvent>(_onRemoveMember);
  }

  void _onLoadGroupSettings(LoadGroupSettings event, Emitter<GroupSettingsState> emit) async {
    emit(GroupSettingsLoading());
    final result = await getGroupDetail(GroupDetailParam(event.groupId));
    final userResult = await authRepository.getCurrentUser();
    String? currentUserId;
    userResult.fold((l) => null, (user) => currentUserId = user.id);

    final historyResult = await getGroupExpenseHistory(GroupExpenseHistoryParam(event.groupId));
    List<GroupMemberBalanceEntity>? memberBalances;
    historyResult.fold((l) => null, (history) => memberBalances = history.memberBalances);

    result.fold(
      (failure) => emit(GroupSettingsError(failure.message)),
      (group) => emit(GroupSettingsLoaded(
        group,
        hasChanges: event.hasChanges,
        currentUserId: currentUserId,
        memberBalances: memberBalances,
      )),
    );
  }

  void _onLeaveGroup(LeaveGroupEvent event, Emitter<GroupSettingsState> emit) async {
     GroupSettingsLoaded? currentLoaded;
     if (state is GroupSettingsLoaded) {
       currentLoaded = state as GroupSettingsLoaded;
     }

     emit(GroupSettingsLoading(
       group: currentLoaded?.group,
       currentUserId: currentLoaded?.currentUserId,
       memberBalances: currentLoaded?.memberBalances,
     ));

     final result = await leaveGroup(event.groupId);
     result.fold(
       (failure) => emit(GroupSettingsError(
         failure.message,
         group: currentLoaded?.group,
         currentUserId: currentLoaded?.currentUserId,
         memberBalances: currentLoaded?.memberBalances,
       )),
       (success) {
         dataRefreshCubit.markMultipleForRefresh([RefreshType.groups, RefreshType.activity]);
         emit(GroupActionSuccess("Left group successfully"));
       },
     );
  }

  void _onRemoveMember(RemoveMemberEvent event, Emitter<GroupSettingsState> emit) async {
     GroupSettingsLoaded? currentLoaded;
     if (state is GroupSettingsLoaded) {
       currentLoaded = state as GroupSettingsLoaded;
     }

     emit(GroupSettingsLoading(
       group: currentLoaded?.group,
       currentUserId: currentLoaded?.currentUserId,
       memberBalances: currentLoaded?.memberBalances,
     ));

     final result = await removeGroupMember(RemoveGroupMemberParams(groupId: event.groupId, userId: event.userId));
     result.fold(
       (failure) => emit(GroupSettingsError(
         failure.message,
         group: currentLoaded?.group,
         currentUserId: currentLoaded?.currentUserId,
         memberBalances: currentLoaded?.memberBalances,
       )),
       (success) {
         dataRefreshCubit.markMultipleForRefresh([RefreshType.groups, RefreshType.activity]);
         add(LoadGroupSettings(event.groupId, hasChanges: true));
         emit(GroupActionSuccess("Member removed successfully", shouldPop: false));
       },
     );
  }

  void _onDeleteGroup(DeleteGroupEvent event, Emitter<GroupSettingsState> emit) async {
     GroupSettingsLoaded? currentLoaded;
     if (state is GroupSettingsLoaded) {
       currentLoaded = state as GroupSettingsLoaded;
     }

     emit(GroupSettingsLoading(
       group: currentLoaded?.group,
       currentUserId: currentLoaded?.currentUserId,
       memberBalances: currentLoaded?.memberBalances,
     ));

     final result = await deleteGroup(event.groupId);
     result.fold(
       (failure) => emit(GroupSettingsError(
         failure.message,
         group: currentLoaded?.group,
         currentUserId: currentLoaded?.currentUserId,
         memberBalances: currentLoaded?.memberBalances,
       )),
       (success) {
         dataRefreshCubit.markMultipleForRefresh([RefreshType.groups, RefreshType.activity]);
         emit(GroupActionSuccess("Deleted group successfully"));
       },
     );
  }
}
