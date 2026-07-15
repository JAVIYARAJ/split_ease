import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/account/domain/entities/category_limit_entity.dart';
import 'package:split_ease/features/account/domain/repository/account_repository.dart';

class GetCategoryLimits implements UseCase<List<CategoryLimitEntity>, NoParams> {
  final AccountRepository repository;

  GetCategoryLimits(this.repository);

  @override
  Future<Either<Failure, List<CategoryLimitEntity>>> call(NoParams params) async {
    return await repository.getCategoryLimits();
  }
}
