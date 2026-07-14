import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';

class DeleteExpenseCommentUseCase {
  final ExpenseRepository repository;

  DeleteExpenseCommentUseCase(this.repository);

  Future<Either<Failure, void>> call({required String commentId}) async {
    return await repository.deleteExpenseComment(commentId: commentId);
  }
}
