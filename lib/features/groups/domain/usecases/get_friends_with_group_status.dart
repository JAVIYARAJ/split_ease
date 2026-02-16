import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/groups/domain/entities/group_friend_entity.dart';
import 'package:split_ease/features/groups/domain/repository/group_repository.dart';

class GetFriendsWithGroupStatus implements UseCase<List<GroupFriendEntity>, GetFriendsWithGroupStatusParam> {
  final GroupRepository groupRepository;

  GetFriendsWithGroupStatus({required this.groupRepository});

  @override
  Future<Either<Failure, List<GroupFriendEntity>>> call(GetFriendsWithGroupStatusParam params) async {
    return await groupRepository.getFriendsWithGroupStatus(params.groupId);
  }
}

class GetFriendsWithGroupStatusParam {
  final String groupId;

  GetFriendsWithGroupStatusParam(this.groupId);
}
