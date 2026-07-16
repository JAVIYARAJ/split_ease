import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';

class DeleteExpenseMediaUseCase implements UseCase<void, String> {
  final ExpenseRepository repository;

  DeleteExpenseMediaUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String mediaId) async {
    return await repository.deleteExpenseMedia(mediaId);
  }
}
