import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/friends/domain/repository/friends_repository.dart';

class GetUnreadFriendRequestCount implements UseCase<int, NoParams> {
  final FriendsRepository friendsRepository;

  GetUnreadFriendRequestCount({required this.friendsRepository});

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    return await friendsRepository.getUnreadFriendRequestCount();
  }
}
