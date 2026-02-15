import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/friends/domain/repository/friends_repository.dart';

class RespondToFriendRequest implements UseCase<void, RespondToFriendRequestParams> {
  final FriendsRepository friendsRepository;

  RespondToFriendRequest({required this.friendsRepository});

  @override
  Future<Either<Failure, void>> call(RespondToFriendRequestParams params) async {
    return await friendsRepository.respondToFriendRequest(params.friendshipId, params.action);
  }
}

class RespondToFriendRequestParams {
  final String friendshipId;
  final String action;

  RespondToFriendRequestParams({
    required this.friendshipId,
    required this.action,
  });
}
