part of 'add_members_bloc.dart';

@immutable
abstract class AddMembersEvent {}

class LoadFriendsForGroup extends AddMembersEvent {
  final String groupId;
  LoadFriendsForGroup(this.groupId);
}

class ToggleFriendSelection extends AddMembersEvent {
  final String userId;
  ToggleFriendSelection(this.userId);
}

class SubmitSelectedFriends extends AddMembersEvent {
  final String groupId;
  SubmitSelectedFriends(this.groupId);
}

class ChangeFriendRole extends AddMembersEvent {
  final String userId;
  final String role;
  ChangeFriendRole(this.userId, this.role);
}

class ChangeSearchQuery extends AddMembersEvent {
  final String query;
  ChangeSearchQuery(this.query);
}
