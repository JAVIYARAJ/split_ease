import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/friends/domain/usecases/friend_join.dart';
import 'package:split_ease/features/friends/domain/usecases/get_my_friends.dart';
import 'package:split_ease/features/friends/domain/usecases/get_unread_friend_request_count.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/services/data_refresh_service.dart';
import '../../domain/entities/friend_entity.dart';
import 'package:split_ease/core/enums/app_enums.dart';
export 'package:split_ease/core/enums/app_enums.dart';

part 'friends_event.dart';

part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final FriendJoin _friendJoin;
  final GetMyFriends _getMyFriends;
  final GetUnreadFriendRequestCount _getUnreadFriendRequestCount;
  final DataRefreshCubit _dataRefreshCubit;

  FriendsBloc({
    required FriendJoin friendJoin,
    required GetMyFriends getMyFriends,
    required GetUnreadFriendRequestCount getUnreadFriendRequestCount,
    required DataRefreshCubit dataRefreshCubit,
  })  : _friendJoin = friendJoin,
        _getMyFriends = getMyFriends,
        _getUnreadFriendRequestCount = getUnreadFriendRequestCount,
        _dataRefreshCubit = dataRefreshCubit,
        super(const FriendsState()) {
    on<LoadFriends>(_onLoadFriends);
    on<FriendQrJoinEvent>(_onQrJoinFriend);
    on<LoadUnreadFriendRequestCount>(_onLoadUnreadCount);
    on<ToggleFriendsFab>((event, emit) => emit(state.copyWith(isFabExtended: event.isExtended)));
  }


  Future<void> _onLoadFriends(LoadFriends event, Emitter<FriendsState> emit) async {
    emit(state.copyWith(status: FriendsStatus.loading));
    final response = await _getMyFriends(NoParams());
    response.fold(
      (failure) => emit(state.copyWith(status: FriendsStatus.failure, errorMessage: failure.message)),
      (friends) => emit(state.copyWith(status: FriendsStatus.success, friends: friends)),
    );
  }

  Future<void> _onQrJoinFriend(FriendQrJoinEvent event, Emitter<FriendsState> emit) async {
    emit(state.copyWith(joinStatus: FriendJoinStatus.loading));
    final response = await _friendJoin(FriendJoinParam(friendId: event.friendId));
    response.fold(
      (error) {
        emit(state.copyWith(joinStatus: FriendJoinStatus.failure, joinErrorMessage: error.message));
      },
      (_) {
        emit(state.copyWith(joinStatus: FriendJoinStatus.success));
        _dataRefreshCubit.markMultipleForRefresh([RefreshType.friends, RefreshType.activity]);
        // Reset join status after success so dialog doesn't show again if state rebuilds
        emit(state.copyWith(joinStatus: FriendJoinStatus.initial));
      },
    );
  }

  Future<void> _onLoadUnreadCount(LoadUnreadFriendRequestCount event, Emitter<FriendsState> emit) async {
    final response = await _getUnreadFriendRequestCount(NoParams());
    response.fold(
      (_) {}, // silently ignore errors for badge count
      (count) => emit(state.copyWith(unreadRequestCount: count)),
    );
  }
}
