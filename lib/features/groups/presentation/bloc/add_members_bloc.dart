import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/groups/domain/entities/group_friend_entity.dart';
import 'package:split_ease/features/groups/domain/usecases/add_friends_to_group.dart';
import 'package:split_ease/features/groups/domain/usecases/get_friends_with_group_status.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
import 'package:split_ease/core/enums/app_enums.dart';
export 'package:split_ease/core/enums/app_enums.dart';

part 'add_members_event.dart';
part 'add_members_state.dart';

class AddMembersBloc extends Bloc<AddMembersEvent, AddMembersState> {
  final GetFriendsWithGroupStatus _getFriendsWithGroupStatus;
  final AddFriendsToGroup _addFriendsToGroup;
  final DataRefreshCubit _dataRefreshCubit; // Changed type and name

  AddMembersBloc({
    required GetFriendsWithGroupStatus getFriendsWithGroupStatus,
    required AddFriendsToGroup addFriendsToGroup,
    required DataRefreshCubit dataRefreshCubit, // Changed type and name
  })  : _getFriendsWithGroupStatus = getFriendsWithGroupStatus,
        _addFriendsToGroup = addFriendsToGroup,
        _dataRefreshCubit = dataRefreshCubit, // Changed name
        super(const AddMembersState()) {
    on<LoadFriendsForGroup>(_onLoadFriends);
    on<ToggleFriendSelection>(_onToggleSelection);
    on<ChangeFriendRole>(_onUpdateRole);
    on<SubmitSelectedFriends>(_onSubmit);
    on<ChangeSearchQuery>((event, emit) {
      emit(state.copyWith(searchQuery: event.query));
    });
  }

  Future<void> _onLoadFriends(LoadFriendsForGroup event, Emitter<AddMembersState> emit) async {
    emit(state.copyWith(status: AddMembersStatus.loading));
    final result = await _getFriendsWithGroupStatus(
      GetFriendsWithGroupStatusParam(event.groupId),
    );
    result.fold(
      (failure) => emit(state.copyWith(status: AddMembersStatus.failure, errorMessage: failure.message)),
      (friends) => emit(state.copyWith(status: AddMembersStatus.loaded, friends: friends)),
    );
  }

  void _onToggleSelection(ToggleFriendSelection event, Emitter<AddMembersState> emit) {
    final updated = Map<String, String>.from(state.selectedRoles);
    if (updated.containsKey(event.userId)) {
      updated.remove(event.userId);
    } else {
      updated[event.userId] = 'user'; // Default role
    }
    emit(state.copyWith(selectedRoles: updated));
  }

  void _onUpdateRole(ChangeFriendRole event, Emitter<AddMembersState> emit) {
    final updated = Map<String, String>.from(state.selectedRoles);
    if (updated.containsKey(event.userId)) {
      updated[event.userId] = event.role;
      emit(state.copyWith(selectedRoles: updated));
    }
  }

  Future<void> _onSubmit(SubmitSelectedFriends event, Emitter<AddMembersState> emit) async {
    if (state.selectedUserIds.isEmpty) return;
    emit(state.copyWith(submitStatus: AddMembersSubmitStatus.submitting));
    final result = await _addFriendsToGroup(
      AddFriendsToGroupParam(
        groupId: event.groupId, 
        userIds: state.selectedUserIds.toList(),
        roles: state.selectedRoles,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(submitStatus: AddMembersSubmitStatus.failure, errorMessage: failure.message)),
      (_) {
        emit(state.copyWith(submitStatus: AddMembersSubmitStatus.success));
        _dataRefreshCubit.markMultipleForRefresh([RefreshType.groups, RefreshType.activity]);
        _dataRefreshCubit.markForRefresh(RefreshType.groupDetail, id: event.groupId);
      },
    );
  }
}
