import 'package:fpdart/fpdart.dart';
import 'package:split_ease/features/expenses/domain/usecases/create_expense_params.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';
import '../../../../core/error/failure.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, void>> createExpense(CreateExpenseParams params);
  Future<Either<Failure, ExpenseDetailEntity>> getExpenseDetail(String expenseId);
}
