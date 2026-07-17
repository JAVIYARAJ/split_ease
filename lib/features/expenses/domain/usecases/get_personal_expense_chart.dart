import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/expenses/domain/entities/personal_expense_chart_entity.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';
import 'package:equatable/equatable.dart';

class GetPersonalExpenseChart implements UseCase<PersonalExpenseChartEntity, GetPersonalExpenseChartParams> {
  final ExpenseRepository repository;

  GetPersonalExpenseChart(this.repository);

  @override
  Future<Either<Failure, PersonalExpenseChartEntity>> call(GetPersonalExpenseChartParams params) async {
    return await repository.getPersonalExpenseChart(
      startDate: params.startDate,
      endDate: params.endDate,
      categoryId: params.categoryId,
      paymentMethodId: params.paymentMethodId,
    );
  }
}

class GetPersonalExpenseChartParams extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final String? categoryId;
  final String? paymentMethodId;

  const GetPersonalExpenseChartParams({
    required this.startDate,
    required this.endDate,
    this.categoryId,
    this.paymentMethodId,
  });

  @override
  List<Object?> get props => [startDate, endDate, categoryId, paymentMethodId];
}
