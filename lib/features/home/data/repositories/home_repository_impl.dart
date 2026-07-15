import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/exception.dart';
import 'package:split_ease/core/error/failure.dart';
import '../../domain/entities/home_dashboard_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, HomeDashboardEntity>> getHomeDashboard() async {
    try {
      final dashboard = await remoteDataSource.getHomeDashboard();
      return right(dashboard);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}
