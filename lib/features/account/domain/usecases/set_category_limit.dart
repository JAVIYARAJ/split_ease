import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/account/domain/repository/account_repository.dart';

class SetCategoryLimitParams {
  final String categoryId;
  final double limitAmount;

  SetCategoryLimitParams({required this.categoryId, required this.limitAmount});
}

class SetCategoryLimit implements UseCase<bool, SetCategoryLimitParams> {
  final AccountRepository repository;

  SetCategoryLimit(this.repository);

  @override
  Future<Either<Failure, bool>> call(SetCategoryLimitParams params) async {
    return await repository.setCategoryLimit(params.categoryId, params.limitAmount);
  }
}
