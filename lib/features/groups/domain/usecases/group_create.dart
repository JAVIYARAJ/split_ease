import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/groups/domain/repository/group_repository.dart';

class GroupCreate implements UseCase<dynamic, CreateGroupParam> {
  final GroupRepository groupRepository;

  GroupCreate({required this.groupRepository});

  @override
  Future<Either<Failure, dynamic>> call(CreateGroupParam params) async {
    return await groupRepository.createGroup(params.name, params.type, params.icon, params.inviteCode);
  }
}

class CreateGroupParam {
  final String name;
  final String? icon;
  final String type;
  final String inviteCode;

  CreateGroupParam({required this.name, required this.icon, required this.type, required this.inviteCode});
}
