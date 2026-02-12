part of 'friend_requests_bloc.dart';

enum FriendRequestsStatus { initial, loading, success, failure }
enum RespondStatus { initial, loading, success, failure }

final class FriendRequestsState {
  final FriendRequestsStatus status;
  final List<FriendRequestEntity> requests;
  final String errorMessage;
  final RespondStatus respondStatus;
  final String respondMessage;

  const FriendRequestsState({
    this.status = FriendRequestsStatus.initial,
    this.requests = const [],
    this.errorMessage = '',
    this.respondStatus = RespondStatus.initial,
    this.respondMessage = '',
  });

  FriendRequestsState copyWith({
    FriendRequestsStatus? status,
    List<FriendRequestEntity>? requests,
    String? errorMessage,
    RespondStatus? respondStatus,
    String? respondMessage,
  }) {
    return FriendRequestsState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      errorMessage: errorMessage ?? this.errorMessage,
      respondStatus: respondStatus ?? this.respondStatus,
      respondMessage: respondMessage ?? this.respondMessage,
    );
  }
}
