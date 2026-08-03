import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/activity_entity.dart';
import '../repositories/activity_repository.dart';

class GetActivityFeedUseCase implements UseCase<List<ActivityEntity>, GetActivityFeedParams> {
  final ActivityRepository repository;

  GetActivityFeedUseCase(this.repository);

  @override
  Future<Either<Failure, List<ActivityEntity>>> call(GetActivityFeedParams params) async {
    return await repository.getActivityFeed(page: params.page, limit: params.limit);
  }
}

class GetActivityFeedParams {
  final int page;
  final int limit;

  const GetActivityFeedParams({this.page = 1, this.limit = 20});
}
