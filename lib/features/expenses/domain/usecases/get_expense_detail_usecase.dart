import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';

import '../../../../core/usecases/use_case.dart';

class GetExpenseDetailUseCase implements UseCase<ExpenseDetailEntity, String> {
  final ExpenseRepository repository;

  GetExpenseDetailUseCase(this.repository);

  @override
  Future<Either<Failure, ExpenseDetailEntity>> call(String params) async {
    return await repository.getExpenseDetail(params);
  }
}
