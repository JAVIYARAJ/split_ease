import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_friend_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_expense_history_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';

import '../../../../core/error/failure.dart';

abstract interface class GroupRepository {
  Future<Either<Failure, String>> insertGroupIcon(File file);

  Future<Either<Failure, dynamic>> createGroup(String name, String type, String? icon, String inviteCode);

  Future<Either<Failure, List<GroupEntity>>> getAllGroups();

  Future<Either<Failure,GroupEntity>> getGroupDetail(String id);

  Future<Either<Failure, String?>> joinGroup(String code);

  Future<Either<Failure, bool>> checkInviteCode(String code);

  Future<Either<Failure, bool>> leaveGroup(String groupId);
  
  Future<Either<Failure, bool>> removeGroupMember(String groupId, String userId);

  Future<Either<Failure, bool>> deleteGroup(String groupId);

  Future<Either<Failure, bool>> updateGroup(String id, String name, String type, String? icon,String inviteCode);

  Future<Either<Failure, List<GroupFriendEntity>>> getFriendsWithGroupStatus(String groupId);

  Future<Either<Failure, void>> addMultipleFriendsToGroup(String groupId, List<String> userIds);

  Future<Either<Failure, GroupExpenseHistoryEntity>> getGroupExpenseHistory(String groupId);

  Future<Either<Failure, List<GroupMemberEntity>>> getGroupMembers(String groupId);

  Future<Either<Failure, List<GroupEntity>>> getCommonGroupsForUsers(List<String> userIds);
}
