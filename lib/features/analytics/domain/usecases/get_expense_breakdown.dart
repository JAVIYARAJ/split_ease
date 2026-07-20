import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import '../entities/expense_breakdown_entity.dart';
import '../repositories/analytics_repository.dart';

class BreakdownParams extends Equatable {
  final String? startDate;
  final String? endDate;

  const BreakdownParams({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class GetExpenseBreakdown {
  final AnalyticsRepository repository;

  GetExpenseBreakdown(this.repository);

  Future<Either<Failure, ExpenseBreakdownEntity>> call(BreakdownParams params) async {
    return await repository.getExpenseBreakdown(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
