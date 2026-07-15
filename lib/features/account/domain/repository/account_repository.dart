
import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/account/domain/entities/category_limit_entity.dart';

abstract interface class AccountRepository {
  Future<Either<Failure, dynamic>> logout();
  Future<Either<Failure, bool>> submitAppFeedback(int rating, String description);
  Future<Either<Failure, List<CategoryLimitEntity>>> getCategoryLimits();
  Future<Either<Failure, bool>> setCategoryLimit(String categoryId, double limitAmount);
  Future<Either<Failure, bool>> deleteCategoryLimit(String categoryId);
}
