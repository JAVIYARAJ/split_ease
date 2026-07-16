import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/expenses/domain/entities/personal_expenses_entity.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';

class GetPersonalExpenses implements UseCase<PersonalExpensesEntity, NoParams> {
  final ExpenseRepository repository;

  GetPersonalExpenses(this.repository);

  @override
  Future<Either<Failure, PersonalExpensesEntity>> call(NoParams params) async {
    return await repository.getPersonalExpenses();
  }
}
