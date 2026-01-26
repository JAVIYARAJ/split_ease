import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';

import '../../../../core/error/failure.dart';

abstract interface class GroupRepository {
  Future<Either<Failure, String>> insertGroupIcon(File file);

  Future<Either<Failure, dynamic>> createGroup(String name, String type, String? icon, String inviteCode);

  Future<Either<Failure, List<GroupEntity>>> getAllGroups();

  Future<Either<Failure,GroupEntity>> getGroupDetail(String id);

  Future<Either<Failure, bool>> joinGroup(String code);

  Future<Either<Failure, bool>> checkInviteCode(String code);

  Future<Either<Failure, bool>> leaveGroup(String groupId);

  Future<Either<Failure, bool>> deleteGroup(String groupId);
}
