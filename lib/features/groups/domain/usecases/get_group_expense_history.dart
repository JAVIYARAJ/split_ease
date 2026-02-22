import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/groups/domain/entities/group_expense_history_entity.dart';
import 'package:split_ease/features/groups/domain/repository/group_repository.dart';

class GetGroupExpenseHistory implements UseCase<GroupExpenseHistoryEntity, GroupExpenseHistoryParam> {
  final GroupRepository groupRepository;

  GetGroupExpenseHistory({required this.groupRepository});

  @override
  Future<Either<Failure, GroupExpenseHistoryEntity>> call(GroupExpenseHistoryParam params) async {
    return await groupRepository.getGroupExpenseHistory(params.groupId);
  }
}

class GroupExpenseHistoryParam {
  final String groupId;

  GroupExpenseHistoryParam(this.groupId);
}
