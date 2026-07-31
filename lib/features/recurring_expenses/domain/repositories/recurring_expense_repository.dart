import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/recurring_expense_entity.dart';

abstract class RecurringExpenseRepository {
  Future<Either<Failure, List<RecurringExpenseEntity>>> getRecurringExpenses();
  Future<Either<Failure, String>> saveRecurringExpense(
    RecurringExpenseEntity template, {
    bool isEdit = false,
  });
  Future<Either<Failure, void>> togglePauseRecurringExpense(
    String templateId,
    bool isPaused,
  );
  Future<Either<Failure, void>> deleteRecurringExpense(String templateId);
  Future<Either<Failure, void>> confirmRecurringExpense(String templateId);
}
