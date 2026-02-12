import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/friends/domain/usecases/friend_join.dart';
import 'package:split_ease/features/friends/domain/usecases/get_my_friends.dart';
import '../../../../core/usecases/use_case.dart';
import '../../domain/entities/friend_entity.dart';

part 'friends_event.dart';

part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final FriendJoin _friendJoin;
  final GetMyFriends _getMyFriends;

  FriendsBloc({
    required FriendJoin friendJoin,
    required GetMyFriends getMyFriends,
  })  : _friendJoin = friendJoin,
        _getMyFriends = getMyFriends,
        super(const FriendsState()) {
    on<LoadFriends>(_onLoadFriends);
    on<FriendQrJoinEvent>(_onQrJoinFriend);
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
    try {
      var response = await _friendJoin(FriendJoinParam(friendId: event.friendId));
      response.fold(
        (error) {
          emit(state.copyWith(joinStatus: FriendJoinStatus.failure, joinErrorMessage: error.message));
        },
        (successId) {
          emit(state.copyWith(joinStatus: FriendJoinStatus.success));
          // Reset join status after success so dialog doesn't show again if state rebuilds
          emit(state.copyWith(joinStatus: FriendJoinStatus.initial));
        },
      );
    } catch (e) {
      emit(state.copyWith(joinStatus: FriendJoinStatus.failure, joinErrorMessage: "Failed to join friend"));
    }
  }
}
