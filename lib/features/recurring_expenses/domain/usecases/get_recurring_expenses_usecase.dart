import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/recurring_expense_entity.dart';
import '../repositories/recurring_expense_repository.dart';

class GetRecurringExpensesUseCase {
  final RecurringExpenseRepository repository;

  GetRecurringExpensesUseCase(this.repository);

  Future<Either<Failure, List<RecurringExpenseEntity>>> call() async {
    return await repository.getRecurringExpenses();
  }
}
