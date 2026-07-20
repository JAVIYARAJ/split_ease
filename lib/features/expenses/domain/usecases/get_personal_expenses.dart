import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/expenses/domain/entities/personal_expenses_entity.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';

class GetPersonalExpenses {
  final ExpenseRepository repository;

  GetPersonalExpenses(this.repository);

  Future<Either<Failure, PersonalExpensesEntity>> call(GetPersonalExpensesParams params) async {
    return await repository.getPersonalExpenses(
      startDate: params.startDate,
      endDate: params.endDate,
      categoryId: params.categoryId,
      paymentMethodId: params.paymentMethodId,
    );
  }
}

class GetPersonalExpensesParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? categoryId;
  final String? paymentMethodId;

  const GetPersonalExpensesParams({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.paymentMethodId,
  });

  @override
  List<Object?> get props => [startDate, endDate, categoryId, paymentMethodId];
}
