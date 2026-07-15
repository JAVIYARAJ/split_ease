import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import '../entities/home_dashboard_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeDashboardEntity>> getHomeDashboard();
}
