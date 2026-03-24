part of 'add_members_bloc.dart';

enum AddMembersStatus { initial, loading, loaded, failure }

enum AddMembersSubmitStatus { initial, submitting, success, failure }

class AddMembersState {
  final AddMembersStatus status;
  final List<GroupFriendEntity> friends;
  final Map<String, String> selectedRoles; // userId -> role ('user' or 'admin')
  final AddMembersSubmitStatus submitStatus;
  final String errorMessage;
  final String searchQuery;

  const AddMembersState({
    this.status = AddMembersStatus.initial,
    this.friends = const [],
    this.selectedRoles = const {},
    this.submitStatus = AddMembersSubmitStatus.initial,
    this.errorMessage = '',
    this.searchQuery = '',
  });

  Set<String> get selectedUserIds => selectedRoles.keys.toSet();

  List<GroupFriendEntity> get alreadyInGroup => friends.where((f) => f.isInGroup).toList();
  List<GroupFriendEntity> get notInGroup => friends.where((f) => !f.isInGroup).toList();

  List<GroupFriendEntity> get filteredInGroup => _filterFriends(alreadyInGroup);
  List<GroupFriendEntity> get filteredNotInGroup => _filterFriends(notInGroup);

  List<GroupFriendEntity> _filterFriends(List<GroupFriendEntity> list) {
    if (searchQuery.isEmpty) return list;
    final query = searchQuery.toLowerCase();
    return list.where((f) {
      return f.fullName.toLowerCase().contains(query) ||
          (f.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  AddMembersState copyWith({
    AddMembersStatus? status,
    List<GroupFriendEntity>? friends,
    Map<String, String>? selectedRoles,
    AddMembersSubmitStatus? submitStatus,
    String? errorMessage,
    String? searchQuery,
  }) {
    return AddMembersState(
      status: status ?? this.status,
      friends: friends ?? this.friends,
      selectedRoles: selectedRoles ?? this.selectedRoles,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
