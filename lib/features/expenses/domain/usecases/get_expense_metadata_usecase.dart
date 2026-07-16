import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_metadata_entity.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';

class GetExpenseMetadataUseCase {
  final ExpenseRepository repository;

  GetExpenseMetadataUseCase(this.repository);

  Future<Either<Failure, ExpenseMetadataEntity>> call() async {
    return await repository.getExpenseMetadata();
  }
}
