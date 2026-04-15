import 'package:fpdart/fpdart.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';
import 'package:split_ease/features/expenses/domain/usecases/create_expense_params.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';

class AddExpenseUseCase implements UseCase<void, CreateExpenseParams> {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateExpenseParams params) async {
    return await repository.createExpense(params);
  }
}
