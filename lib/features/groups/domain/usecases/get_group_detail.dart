import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';

import '../repository/group_repository.dart';

class GetGroupDetail implements UseCase<GroupEntity, GroupDetailParam> {
  final GroupRepository groupRepository;

  GetGroupDetail({required this.groupRepository});

  @override
  Future<Either<Failure, GroupEntity>> call(GroupDetailParam params) async {
    return await groupRepository.getGroupDetail(params.id);
  }
}

class GroupDetailParam {
  final String id;

  GroupDetailParam(this.id);
}
