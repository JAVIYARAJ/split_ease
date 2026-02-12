part of 'friends_bloc.dart';

enum FriendsStatus { initial, loading, success, failure }

enum FriendJoinStatus { initial, loading, success, failure }

class FriendsState {
  final FriendsStatus status;
  final List<FriendEntity> friends;
  final String errorMessage;
  final FriendJoinStatus joinStatus;
  final String joinErrorMessage;

  const FriendsState({
    this.status = FriendsStatus.initial,
    this.friends = const [],
    this.errorMessage = '',
    this.joinStatus = FriendJoinStatus.initial,
    this.joinErrorMessage = '',
  });

  FriendsState copyWith({
    FriendsStatus? status,
    List<FriendEntity>? friends,
    String? errorMessage,
    FriendJoinStatus? joinStatus,
    String? joinErrorMessage,
  }) {
    return FriendsState(
      status: status ?? this.status,
      friends: friends ?? this.friends,
      errorMessage: errorMessage ?? this.errorMessage,
      joinStatus: joinStatus ?? this.joinStatus,
      joinErrorMessage: joinErrorMessage ?? this.joinErrorMessage,
    );
  }
}