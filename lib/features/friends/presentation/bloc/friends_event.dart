part of 'friends_bloc.dart';

@immutable
sealed class FriendsEvent {}

class LoadFriends extends FriendsEvent {}

class FriendQrJoinEvent extends FriendsEvent{
  final String friendId;

  FriendQrJoinEvent({required this.friendId});
}

class LoadUnreadFriendRequestCount extends FriendsEvent {}

class ToggleFriendsFab extends FriendsEvent {
  final bool isExtended;
  ToggleFriendsFab(this.isExtended);
}