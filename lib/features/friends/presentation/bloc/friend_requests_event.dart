part of 'friend_requests_bloc.dart';

@immutable
sealed class FriendRequestsEvent {}

final class LoadFriendRequests extends FriendRequestsEvent {}

final class RespondToRequest extends FriendRequestsEvent {
  final String friendshipId;
  final String action; // 'accept' or 'reject'

  RespondToRequest({required this.friendshipId, required this.action});
}
