import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/groups/domain/repository/group_repository.dart';

class AddFriendsToGroup implements UseCase<void, AddFriendsToGroupParam> {
  final GroupRepository groupRepository;

  AddFriendsToGroup({required this.groupRepository});

  @override
  Future<Either<Failure, void>> call(AddFriendsToGroupParam params) async {
    return await groupRepository.addMultipleFriendsToGroup(params.groupId, params.userIds);
  }
}

class AddFriendsToGroupParam {
  final String groupId;
  final List<String> userIds;

  AddFriendsToGroupParam({required this.groupId, required this.userIds});
}
