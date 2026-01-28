import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import '../../../../core/error/failure.dart';
import '../repository/group_repository.dart';

class UpdateGroup implements UseCase<bool, UpdateGroupParam> {
  final GroupRepository repository;

  UpdateGroup({required this.repository});

  @override
  Future<Either<Failure, bool>> call(UpdateGroupParam params) async {
    return await repository.updateGroup(params.id, params.name, params.type, params.icon,params.inviteCode);
  }
}

class UpdateGroupParam {
  final String id;
  final String name;
  final String type;
  final String? icon;
  final String inviteCode;

  UpdateGroupParam({required this.id, required this.name, required this.type, this.icon,required this.inviteCode});
}
