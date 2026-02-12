import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/friends/domain/entities/friend_request_entity.dart';
import 'package:split_ease/features/friends/domain/repository/friends_repository.dart';

class GetFriendRequests implements UseCase<List<FriendRequestEntity>, NoParams> {
  final FriendsRepository friendsRepository;

  GetFriendRequests({required this.friendsRepository});

  @override
  Future<Either<Failure, List<FriendRequestEntity>>> call(NoParams params) async {
    return await friendsRepository.getFriendRequests();
  }
}
