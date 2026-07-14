import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';

class GetExpenseComments {
  final ExpenseRepository repository;

  GetExpenseComments(this.repository);

  Future<Either<Failure, List<ExpenseCommentEntity>>> call(String expenseId) async {
    return await repository.getExpenseComments(expenseId);
  }
}
