import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../repositories/expense_repository.dart';

class RestoreExpenseUseCase implements UseCase<void, String> {
  final ExpenseRepository repository;

  RestoreExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String expenseId) async {
    return await repository.restoreExpense(expenseId);
  }
}
