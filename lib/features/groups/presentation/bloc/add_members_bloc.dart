import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/groups/domain/entities/group_friend_entity.dart';
import 'package:split_ease/features/groups/domain/usecases/add_friends_to_group.dart';
import 'package:split_ease/features/groups/domain/usecases/get_friends_with_group_status.dart';

part 'add_members_event.dart';
part 'add_members_state.dart';

class AddMembersBloc extends Bloc<AddMembersEvent, AddMembersState> {
  final GetFriendsWithGroupStatus _getFriendsWithGroupStatus;
  final AddFriendsToGroup _addFriendsToGroup;

  AddMembersBloc({
    required GetFriendsWithGroupStatus getFriendsWithGroupStatus,
    required AddFriendsToGroup addFriendsToGroup,
  })  : _getFriendsWithGroupStatus = getFriendsWithGroupStatus,
        _addFriendsToGroup = addFriendsToGroup,
        super(const AddMembersState()) {
    on<LoadFriendsForGroup>(_onLoadFriends);
    on<ToggleFriendSelection>(_onToggleSelection);
    on<SubmitSelectedFriends>(_onSubmit);
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
    final updated = Set<String>.from(state.selectedUserIds);
    if (updated.contains(event.userId)) {
      updated.remove(event.userId);
    } else {
      updated.add(event.userId);
    }
    emit(state.copyWith(selectedUserIds: updated));
  }

  Future<void> _onSubmit(SubmitSelectedFriends event, Emitter<AddMembersState> emit) async {
    if (state.selectedUserIds.isEmpty) return;
    emit(state.copyWith(submitStatus: AddMembersSubmitStatus.submitting));
    final result = await _addFriendsToGroup(
      AddFriendsToGroupParam(groupId: event.groupId, userIds: state.selectedUserIds.toList()),
    );
    result.fold(
      (failure) => emit(state.copyWith(submitStatus: AddMembersSubmitStatus.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(submitStatus: AddMembersSubmitStatus.success)),
    );
  }
}
