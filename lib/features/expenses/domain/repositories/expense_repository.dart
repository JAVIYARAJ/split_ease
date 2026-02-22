import 'package:fpdart/fpdart.dart';
import 'package:split_ease/features/expenses/domain/usecases/create_expense_params.dart';

import '../../../../core/error/failure.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, void>> createExpense(CreateExpenseParams params);
}
