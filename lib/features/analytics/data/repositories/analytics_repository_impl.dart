import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/exception.dart';
import 'package:split_ease/core/error/failure.dart';
import '../../domain/entities/expense_breakdown_entity.dart';
import '../../domain/entities/category_expense_item_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_data_source.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ExpenseBreakdownEntity>> getExpenseBreakdown({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final breakdown = await remoteDataSource.getExpenseBreakdown(
        startDate: startDate,
        endDate: endDate,
      );
      return right(breakdown);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryExpenseItemEntity>>> getCategoryExpensesPaginated({
    required String categoryId,
    String? startDate,
    String? endDate,
    required int offset,
    required int limit,
  }) async {
    try {
      final items = await remoteDataSource.getCategoryExpensesPaginated(
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
        offset: offset,
        limit: limit,
      );
      return right(items);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}
