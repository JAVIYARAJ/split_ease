import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/friends/domain/entities/friend_entity.dart';
import 'package:split_ease/features/friends/domain/repository/friends_repository.dart';

class GetMyFriends implements UseCase<List<FriendEntity>, NoParams> {
  final FriendsRepository friendsRepository;

  GetMyFriends({required this.friendsRepository});

  @override
  Future<Either<Failure, List<FriendEntity>>> call(NoParams params) async {
    return await friendsRepository.getMyFriends();
  }
}

