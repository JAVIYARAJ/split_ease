import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import '../entities/advertisement_entity.dart';
import '../repositories/home_repository.dart';

class GetAdvertisementsUseCase implements UseCase<List<AdvertisementEntity>, DateTime> {
  final HomeRepository repository;

  GetAdvertisementsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AdvertisementEntity>>> call(DateTime params) async {
    return await repository.getAdvertisements(params);
  }
}
