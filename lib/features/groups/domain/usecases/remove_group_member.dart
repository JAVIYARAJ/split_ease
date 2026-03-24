import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../repository/group_repository.dart';

class RemoveGroupMember implements UseCase<bool, RemoveGroupMemberParams> {
  final GroupRepository groupRepository;

  RemoveGroupMember({required this.groupRepository});

  @override
  Future<Either<Failure, bool>> call(RemoveGroupMemberParams params) async {
    return await groupRepository.removeGroupMember(params.groupId, params.userId);
  }
}

class RemoveGroupMemberParams {
  final String groupId;
  final String userId;

  RemoveGroupMemberParams({required this.groupId, required this.userId});
}
