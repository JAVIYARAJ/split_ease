import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/friends/domain/entities/friend_expense_history_entity.dart';
import 'package:split_ease/features/friends/domain/entities/friend_request_entity.dart';
import '../entities/friend_entity.dart';

abstract interface class FriendsRepository {
  Future<Either<Failure, void>> joinFriend(String friendId);
  Future<Either<Failure, List<FriendEntity>>> getMyFriends();
  Future<Either<Failure, List<FriendRequestEntity>>> getFriendRequests();
  Future<Either<Failure, void>> respondToFriendRequest(String friendshipId, String action);
  Future<Either<Failure, int>> getUnreadFriendRequestCount();
  Future<Either<Failure, FriendExpenseHistoryEntity>> getFriendExpenseHistory(String friendId);
}
