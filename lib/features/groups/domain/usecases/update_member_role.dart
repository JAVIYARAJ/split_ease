import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../repository/group_repository.dart';

class UpdateMemberRole implements UseCase<bool, UpdateMemberRoleParams> {
  final GroupRepository repository;

  UpdateMemberRole(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdateMemberRoleParams params) async {
    return await repository.updateGroupMemberRole(
      params.groupId,
      params.userId,
      params.newRole,
    );
  }
}

class UpdateMemberRoleParams extends Equatable {
  final String groupId;
  final String userId;
  final String newRole;

  const UpdateMemberRoleParams({
    required this.groupId,
    required this.userId,
    required this.newRole,
  });

  @override
  List<Object?> get props => [groupId, userId, newRole];
}
