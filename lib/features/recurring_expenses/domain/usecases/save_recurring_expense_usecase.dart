import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/recurring_expense_entity.dart';
import '../repositories/recurring_expense_repository.dart';

class SaveRecurringExpenseUseCase {
  final RecurringExpenseRepository repository;

  SaveRecurringExpenseUseCase(this.repository);

  Future<Either<Failure, String>> call(
    RecurringExpenseEntity template, {
    bool isEdit = false,
  }) async {
    return await repository.saveRecurringExpense(template, isEdit: isEdit);
  }
}
