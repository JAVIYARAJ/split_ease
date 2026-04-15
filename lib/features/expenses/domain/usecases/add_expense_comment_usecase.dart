import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../repositories/expense_repository.dart';

class AddExpenseCommentUseCase {
  final ExpenseRepository repository;

  AddExpenseCommentUseCase(this.repository);

  Future<Either<Failure, void>> call({required String expenseId, required String comment}) async {
    return await repository.addExpenseComment(expenseId: expenseId, comment: comment);
  }
}
