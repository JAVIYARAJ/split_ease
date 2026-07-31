import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../repositories/recurring_expense_repository.dart';

class DeleteRecurringExpenseUseCase {
  final RecurringExpenseRepository repository;

  DeleteRecurringExpenseUseCase(this.repository);

  Future<Either<Failure, void>> call(String templateId) async {
    return await repository.deleteRecurringExpense(templateId);
  }
}
