import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/exception.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_expense_history_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_friend_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';

import '../../domain/repository/group_repository.dart';
import '../datasources/group_remote_data_source.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource dataSource;

  GroupRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<GroupMemberEntity>>> getGroupMembers(String groupId) async {
    try {
      final response = await dataSource.getGroupMembers(groupId);
      return right(response);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, String>> insertGroupIcon(File file) async {
    try {
      var response = await dataSource.insertGroupImage(file);
      return right(response);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, dynamic>> createGroup(String name, String type, String? icon, String inviteCode) async{
    try{
      var response = await dataSource.createGroup(name, type, icon, inviteCode);
      return right(response);
    } on ServerException catch(error){
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<GroupEntity>>> getAllGroups() async{
    try{
      var response = await dataSource.getAllGroups();
      return right(response);
    } on ServerException catch(error){
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> getGroupDetail(String id) async{
    try{
      var response = await dataSource.getGroupDetail(id);
      return right(response);
    } on ServerException catch(error){
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, String?>> joinGroup(String code) async {
     try{
      var response = await dataSource.joinGroup(code);
      return right(response);
    } on ServerException catch(error){
      return left(Failure(message: error.message));
    }
  }


  @override
  Future<Either<Failure, bool>> checkInviteCode(String code) async {
    try {
      var response = await dataSource.checkInviteCode(code);
      return right(response);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }
  @override
  Future<Either<Failure, bool>> leaveGroup(String groupId) async {
    try {
      var response = await dataSource.leaveGroup(groupId);
      return right(response);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, bool>> removeGroupMember(String groupId, String userId) async {
    try {
      var response = await dataSource.removeMember(groupId, userId);
      return right(response);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteGroup(String groupId) async {
    try {
      var response = await dataSource.deleteGroup(groupId);
      return right(response);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, bool>> updateGroup(String id, String name, String type, String? icon,String inviteCode) async {
     try {
      var response = await dataSource.updateGroup(id, name, type, icon,inviteCode);
      return right(response);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<GroupFriendEntity>>> getFriendsWithGroupStatus(String groupId) async {
    try {
      final models = await dataSource.getFriendsWithGroupStatus(groupId);
      return right(models);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, void>> addMultipleFriendsToGroup(String groupId, List<String> userIds) async {
    try {
      await dataSource.addMultipleFriendsToGroup(groupId, userIds);
      return right(null);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, GroupExpenseHistoryEntity>> getGroupExpenseHistory(String groupId) async {
    try {
      final model = await dataSource.getGroupExpenseHistory(groupId);
      return right(model);
    } on ServerException catch (error) {
       return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<GroupEntity>>> getCommonGroupsForUsers(List<String> userIds) async {
    try {
      final response = await dataSource.getCommonGroupsForUsers(userIds);
      return right(response);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }
}
