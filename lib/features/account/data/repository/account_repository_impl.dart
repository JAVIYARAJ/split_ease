
import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/exception.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/account/data/datasources/account_remote_data_source.dart';
import 'package:split_ease/features/account/domain/repository/account_repository.dart';
import 'package:split_ease/features/account/domain/entities/category_limit_entity.dart';
import 'package:split_ease/features/account/data/models/category_limit_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource accountRemoteDataSource;

  AccountRepositoryImpl({required this.accountRemoteDataSource});

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      var response = await accountRemoteDataSource.logout();
      return right(response);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }
  @override
  Future<Either<Failure, bool>> submitAppFeedback(int rating, String description) async {
    try {
      var response = await accountRemoteDataSource.submitAppFeedback(rating, description);
      return right(response);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, List<CategoryLimitEntity>>> getCategoryLimits() async {
    try {
      final response = await accountRemoteDataSource.getCategoryLimits();
      final List<CategoryLimitEntity> limits = response
          .map<CategoryLimitEntity>((e) => CategoryLimitModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return right(limits);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, bool>> setCategoryLimit(String categoryId, double limitAmount) async {
    try {
      final response = await accountRemoteDataSource.setCategoryLimit(categoryId, limitAmount);
      return right(response);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCategoryLimit(String categoryId) async {
    try {
      final response = await accountRemoteDataSource.deleteCategoryLimit(categoryId);
      return right(response);
    } on ServerException catch (error) {
      return left(Failure(message: error.message));
    }
  }
}
