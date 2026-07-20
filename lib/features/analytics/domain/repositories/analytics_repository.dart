import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import '../entities/expense_breakdown_entity.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, ExpenseBreakdownEntity>> getExpenseBreakdown({
    String? startDate,
    String? endDate,
  });
}
