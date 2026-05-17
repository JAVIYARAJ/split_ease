import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/exception.dart';

import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/friends/domain/entities/friend_entity.dart';
import 'package:split_ease/features/friends/domain/entities/friend_request_entity.dart';
import 'package:split_ease/features/friends/domain/entities/friend_expense_history_entity.dart';

import '../../domain/repository/friends_repository.dart';
import '../datasources/friends_remote_data_source.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource friendsRemoteDataSource;

  FriendsRepositoryImpl({required this.friendsRemoteDataSource});

  @override
  Future<Either<Failure, void>> joinFriend(String friendId) async {
    try {
      await friendsRemoteDataSource.joinFriends(friendId);
      return right(null);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<FriendEntity>>> getMyFriends() async {
    try {
      final models = await friendsRemoteDataSource.getMyFriends();
      return right(models);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<FriendRequestEntity>>> getFriendRequests() async {
    try {
      final models = await friendsRemoteDataSource.getFriendRequests();
      return right(models);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, void>> respondToFriendRequest(String friendshipId, String action) async {
    try {
      await friendsRemoteDataSource.respondToFriendRequest(friendshipId, action);
      return right(null);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadFriendRequestCount() async {
    try {
      final count = await friendsRemoteDataSource.getUnreadFriendRequestCount();
      return right(count);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, FriendExpenseHistoryEntity>> getFriendExpenseHistory(String friendId) async {
    try {
      final model = await friendsRemoteDataSource.getFriendExpenseHistory(friendId);
      return right(model);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }
}
