import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../repository/group_repository.dart';

class LeaveGroup implements UseCase<bool, String> {
  final GroupRepository groupRepository;

  LeaveGroup({required this.groupRepository});

  @override
  Future<Either<Failure, bool>> call(String params) async {
    return await groupRepository.leaveGroup(params);
  }
}
