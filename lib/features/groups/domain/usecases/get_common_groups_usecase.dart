import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/groups/domain/repository/group_repository.dart';

class GetCommonGroupsUseCase implements UseCase<List<GroupEntity>, List<String>> {
  final GroupRepository repository;

  GetCommonGroupsUseCase(this.repository);

  @override
  Future<Either<Failure, List<GroupEntity>>> call(List<String> params) async {
    return await repository.getCommonGroupsForUsers(params);
  }
}
