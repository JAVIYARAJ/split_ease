part of 'friends_bloc.dart';


class FriendsState {
  final FriendsStatus status;
  final List<FriendEntity> friends;
  final String errorMessage;
  final FriendJoinStatus joinStatus;
  final String joinErrorMessage;
  final int unreadRequestCount;
  final bool isFabExtended;

  const FriendsState({
    this.status = FriendsStatus.initial,
    this.friends = const [],
    this.errorMessage = '',
    this.joinStatus = FriendJoinStatus.initial,
    this.joinErrorMessage = '',
    this.unreadRequestCount = 0,
    this.isFabExtended = true,
  });

  FriendsState copyWith({
    FriendsStatus? status,
    List<FriendEntity>? friends,
    String? errorMessage,
    FriendJoinStatus? joinStatus,
    String? joinErrorMessage,
    int? unreadRequestCount,
    bool? isFabExtended,
  }) {
    return FriendsState(
      status: status ?? this.status,
      friends: friends ?? this.friends,
      errorMessage: errorMessage ?? this.errorMessage,
      joinStatus: joinStatus ?? this.joinStatus,
      joinErrorMessage: joinErrorMessage ?? this.joinErrorMessage,
      unreadRequestCount: unreadRequestCount ?? this.unreadRequestCount,
      isFabExtended: isFabExtended ?? this.isFabExtended,
    );
  }

}