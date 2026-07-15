import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import '../entities/expense_breakdown_entity.dart';
import '../repositories/analytics_repository.dart';

class GetExpenseBreakdown implements UseCase<ExpenseBreakdownEntity, NoParams> {
  final AnalyticsRepository repository;

  GetExpenseBreakdown(this.repository);

  @override
  Future<Either<Failure, ExpenseBreakdownEntity>> call(NoParams params) async {
    return await repository.getExpenseBreakdown();
  }
}
