import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/exception.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/splash/data/datasources/splash_remote_data_source.dart';
import 'package:split_ease/features/splash/domain/repository/splash_repository.dart';

class SplashRepositoryImpl implements SplashRepository {
  final SplashRemoteDataSource dataSource;

  SplashRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, bool>> isUserActiveSession() async {
    try {
      return right(await dataSource.isUserLogin());
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
