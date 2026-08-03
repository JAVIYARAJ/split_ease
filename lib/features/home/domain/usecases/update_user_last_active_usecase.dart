import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import '../repositories/home_repository.dart';

class UpdateUserLastActiveUseCase implements UseCase<void, String> {
  final HomeRepository repository;

  UpdateUserLastActiveUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String userId) async {
    return await repository.updateUserLastActive(userId);
  }
}
