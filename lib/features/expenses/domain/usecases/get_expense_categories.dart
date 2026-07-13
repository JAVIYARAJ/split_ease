import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';

class GetExpenseCategories implements UseCase<List<ExpenseCategoryEntity>, NoParams> {
  final ExpenseRepository repository;

  GetExpenseCategories(this.repository);

  @override
  Future<Either<Failure, List<ExpenseCategoryEntity>>> call(NoParams params) async {
    return await repository.getExpenseCategories();
  }
}
