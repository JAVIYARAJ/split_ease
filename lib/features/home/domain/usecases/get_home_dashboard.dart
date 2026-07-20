import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import '../entities/home_dashboard_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeDashboardParams {
  final DateTime? startDate;
  final DateTime? endDate;

  const GetHomeDashboardParams({this.startDate, this.endDate});
}

class GetHomeDashboard implements UseCase<HomeDashboardEntity, GetHomeDashboardParams> {
  final HomeRepository repository;

  GetHomeDashboard(this.repository);

  @override
  Future<Either<Failure, HomeDashboardEntity>> call(GetHomeDashboardParams params) async {
    return await repository.getHomeDashboard(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
