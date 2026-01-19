part of 'friends_bloc.dart';

@immutable
sealed class FriendsState {}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<FriendEntity> friends;
  FriendsLoaded(this.friends);
}

class FriendsError extends FriendsState {
  final String message;
  FriendsError(this.message);
}
