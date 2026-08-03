import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import '../entities/home_dashboard_entity.dart';
import '../entities/advertisement_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeDashboardEntity>> getHomeDashboard({DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, List<AdvertisementEntity>>> getAdvertisements(DateTime clientDate);
  Future<Either<Failure, void>> updateUserLastActive(String userId);
}
