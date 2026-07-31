import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../repositories/recurring_expense_repository.dart';

class TogglePauseRecurringExpenseUseCase {
  final RecurringExpenseRepository repository;

  TogglePauseRecurringExpenseUseCase(this.repository);

  Future<Either<Failure, void>> call(String templateId, bool isPaused) async {
    return await repository.togglePauseRecurringExpense(templateId, isPaused);
  }
}
