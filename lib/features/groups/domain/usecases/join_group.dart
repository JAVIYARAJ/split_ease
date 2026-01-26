import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/groups/domain/repository/group_repository.dart';

class JoinGroup implements UseCase<void, String> {
  final GroupRepository groupRepository;

  JoinGroup({required this.groupRepository});

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await groupRepository.joinGroup(params);
  }
}
