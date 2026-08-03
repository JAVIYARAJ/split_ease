import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import '../entities/expense_breakdown_entity.dart';
import '../entities/category_expense_item_entity.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, ExpenseBreakdownEntity>> getExpenseBreakdown({
    String? startDate,
    String? endDate,
  });

  Future<Either<Failure, List<CategoryExpenseItemEntity>>> getCategoryExpensesPaginated({
    required String categoryId,
    String? startDate,
    String? endDate,
    required int offset,
    required int limit,
  });
}
