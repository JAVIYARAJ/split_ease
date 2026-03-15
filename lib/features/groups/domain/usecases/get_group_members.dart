import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';
import 'package:split_ease/features/groups/domain/repository/group_repository.dart';

import '../../../../core/usecases/use_case.dart';

class GetGroupMembers implements UseCase<List<GroupMemberEntity>, String> {
  final GroupRepository repository;

  GetGroupMembers(this.repository);

  @override
  Future<Either<Failure, List<GroupMemberEntity>>> call(String groupId) {
    return repository.getGroupMembers(groupId);
  }
}
