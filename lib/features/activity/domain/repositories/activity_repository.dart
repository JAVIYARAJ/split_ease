import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/activity_entity.dart';

abstract interface class ActivityRepository {
  Future<Either<Failure, List<ActivityEntity>>> getActivityFeed();
}
