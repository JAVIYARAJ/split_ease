
import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/exception.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/account/data/datasources/account_remote_data_source.dart';
import 'package:split_ease/features/account/domain/repository/account_repository.dart';

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
}
