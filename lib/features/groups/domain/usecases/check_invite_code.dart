import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/groups/domain/repository/group_repository.dart';

class CheckInviteCode implements UseCase<bool, String> {
  final GroupRepository groupRepository;

  CheckInviteCode({required this.groupRepository});

  @override
  Future<Either<Failure, bool>> call(String params) async {
    return await groupRepository.checkInviteCode(params);
  }
}
