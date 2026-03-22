import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/friends/domain/entities/friend_request_entity.dart';
import 'package:split_ease/features/friends/domain/usecases/get_friend_requests.dart';
import 'package:split_ease/features/friends/domain/usecases/respond_to_friend_request.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';

part 'friend_requests_event.dart';
part 'friend_requests_state.dart';

class FriendRequestsBloc extends Bloc<FriendRequestsEvent, FriendRequestsState> {
  final GetFriendRequests _getFriendRequests;
  final RespondToFriendRequest _respondToFriendRequest;
  final DataRefreshCubit _dataRefreshCubit; // Changed type and name

  FriendRequestsBloc({
    required GetFriendRequests getFriendRequests,
    required RespondToFriendRequest respondToFriendRequest,
    required DataRefreshCubit dataRefreshCubit, // Changed type and name
  })  : _getFriendRequests = getFriendRequests,
        _respondToFriendRequest = respondToFriendRequest,
        _dataRefreshCubit = dataRefreshCubit, // Changed name
        super(const FriendRequestsState()) {
    on<LoadFriendRequests>(_onLoadFriendRequests);
    on<RespondToRequest>(_onRespondToRequest);
  }

  Future<void> _onLoadFriendRequests(LoadFriendRequests event, Emitter<FriendRequestsState> emit) async {
    emit(state.copyWith(status: FriendRequestsStatus.loading));
    final response = await _getFriendRequests(NoParams());
    response.fold(
      (failure) => emit(state.copyWith(status: FriendRequestsStatus.failure, errorMessage: failure.message)),
      (requests) => emit(state.copyWith(status: FriendRequestsStatus.success, requests: requests)),
    );
  }

  Future<void> _onRespondToRequest(RespondToRequest event, Emitter<FriendRequestsState> emit) async {
    emit(state.copyWith(respondStatus: RespondStatus.loading));
    final response = await _respondToFriendRequest(RespondToFriendRequestParams(
      friendshipId: event.friendshipId,
      action: event.action,
    ));
    response.fold(
      (failure) => emit(state.copyWith(respondStatus: RespondStatus.failure, respondMessage: failure.message)),
      (_) {
        // Optimistic update: remove the request from the list
        final updatedRequests = state.requests.where((r) => r.friendshipId != event.friendshipId).toList();
        
        emit(state.copyWith(
          respondStatus: RespondStatus.success,
          respondMessage: "Request ${event.action}ed successfully",
          requests: updatedRequests,
        ));
        
        _dataRefreshCubit.markMultipleForRefresh([RefreshType.friends, RefreshType.activity]);
        
        // Reset status
        emit(state.copyWith(respondStatus: RespondStatus.initial));
      },
    );
  }
}
