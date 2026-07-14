import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';

class UpdateExpenseCommentUseCase {
  final ExpenseRepository repository;

  UpdateExpenseCommentUseCase(this.repository);

  Future<Either<Failure, void>> call({required String commentId, required String comment}) async {
    return await repository.updateExpenseComment(commentId: commentId, comment: comment);
  }
}
