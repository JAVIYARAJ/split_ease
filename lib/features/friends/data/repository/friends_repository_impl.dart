import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/exception.dart';

import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/friends/domain/entities/friend_entity.dart';
import 'package:split_ease/features/friends/domain/entities/friend_request_entity.dart';

import '../../domain/repository/friends_repository.dart';
import '../datasources/friends_remote_data_source.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource friendsRemoteDataSource;

  FriendsRepositoryImpl({required this.friendsRemoteDataSource});

  @override
  Future<Either<Failure, String?>> joinFriend(String friendId) async{
    try {
      var response = await friendsRemoteDataSource.joinFriends(friendId);
      return right(response);
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
}
