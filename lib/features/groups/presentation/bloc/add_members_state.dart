part of 'add_members_bloc.dart';

enum AddMembersStatus { initial, loading, loaded, failure }

enum AddMembersSubmitStatus { initial, submitting, success, failure }

class AddMembersState {
  final AddMembersStatus status;
  final List<GroupFriendEntity> friends;
  final Set<String> selectedUserIds;
  final AddMembersSubmitStatus submitStatus;
  final String errorMessage;

  const AddMembersState({
    this.status = AddMembersStatus.initial,
    this.friends = const [],
    this.selectedUserIds = const {},
    this.submitStatus = AddMembersSubmitStatus.initial,
    this.errorMessage = '',
  });

  List<GroupFriendEntity> get alreadyInGroup => friends.where((f) => f.isInGroup).toList();
  List<GroupFriendEntity> get notInGroup => friends.where((f) => !f.isInGroup).toList();

  AddMembersState copyWith({
    AddMembersStatus? status,
    List<GroupFriendEntity>? friends,
    Set<String>? selectedUserIds,
    AddMembersSubmitStatus? submitStatus,
    String? errorMessage,
  }) {
    return AddMembersState(
      status: status ?? this.status,
      friends: friends ?? this.friends,
      selectedUserIds: selectedUserIds ?? this.selectedUserIds,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
