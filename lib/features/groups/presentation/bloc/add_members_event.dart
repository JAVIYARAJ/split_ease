part of 'add_members_bloc.dart';

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

class ChangeSearchQuery extends AddMembersEvent {
  final String query;
  ChangeSearchQuery(this.query);
}
