import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../entities/activity_entity.dart';
import '../repositories/activity_repository.dart';

class GetActivityFeedUseCase implements UseCase<List<ActivityEntity>, NoParams> {
  final ActivityRepository repository;

  GetActivityFeedUseCase(this.repository);

  @override
  Future<Either<Failure, List<ActivityEntity>>> call(NoParams params) async {
    return await repository.getActivityFeed();
  }
}
