import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';

import '../repository/friends_repository.dart';

class FriendJoin implements UseCase<void, FriendJoinParam> {
  final FriendsRepository friendsRepository;

  FriendJoin({required this.friendsRepository});

  @override
  Future<Either<Failure, void>> call(FriendJoinParam params) async {
    return await friendsRepository.joinFriend(params.friendId);
  }
}

class FriendJoinParam {
  final String friendId;

  FriendJoinParam({required this.friendId});
}
