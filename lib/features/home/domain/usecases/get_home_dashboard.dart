import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import '../entities/home_dashboard_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeDashboard implements UseCase<HomeDashboardEntity, NoParams> {
  final HomeRepository repository;

  GetHomeDashboard(this.repository);

  @override
  Future<Either<Failure, HomeDashboardEntity>> call(NoParams params) async {
    return await repository.getHomeDashboard();
  }
}
