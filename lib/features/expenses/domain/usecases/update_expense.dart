import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../repositories/expense_repository.dart';
import 'update_expense_params.dart';

class UpdateExpense implements UseCase<void, UpdateExpenseParams> {
  final ExpenseRepository repository;

  UpdateExpense({required this.repository});

  @override
  Future<Either<Failure, void>> call(UpdateExpenseParams params) async {
    return await repository.updateExpense(params);
  }
}
