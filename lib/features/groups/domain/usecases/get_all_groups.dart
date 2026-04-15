import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/groups/domain/repository/group_repository.dart';

class GetAllGroups implements UseCase<List<GroupEntity>,NoParams> {
  final GroupRepository groupRepository;

  GetAllGroups({required this.groupRepository});

  @override
  Future<Either<Failure, List<GroupEntity>>> call(NoParams params) async{
    return await groupRepository.getAllGroups();
  }
}

