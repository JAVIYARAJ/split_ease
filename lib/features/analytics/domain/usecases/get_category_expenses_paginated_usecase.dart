import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import '../entities/category_expense_item_entity.dart';
import '../repositories/analytics_repository.dart';

class GetCategoryExpensesPaginatedParams {
  final String categoryId;
  final String? startDate;
  final String? endDate;
  final int offset;
  final int limit;

  const GetCategoryExpensesPaginatedParams({
    required this.categoryId,
    this.startDate,
    this.endDate,
    required this.offset,
    required this.limit,
  });
}

class GetCategoryExpensesPaginatedUseCase {
  final AnalyticsRepository repository;

  GetCategoryExpensesPaginatedUseCase(this.repository);

  Future<Either<Failure, List<CategoryExpenseItemEntity>>> call(
    GetCategoryExpensesPaginatedParams params,
  ) {
    return repository.getCategoryExpensesPaginated(
      categoryId: params.categoryId,
      startDate: params.startDate,
      endDate: params.endDate,
      offset: params.offset,
      limit: params.limit,
    );
  }
}
