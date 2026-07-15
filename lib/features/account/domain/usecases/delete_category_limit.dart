import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/account/domain/repository/account_repository.dart';

class DeleteCategoryLimitParams {
  final String categoryId;

  DeleteCategoryLimitParams({required this.categoryId});
}

class DeleteCategoryLimit implements UseCase<bool, DeleteCategoryLimitParams> {
  final AccountRepository repository;

  DeleteCategoryLimit(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteCategoryLimitParams params) async {
    return await repository.deleteCategoryLimit(params.categoryId);
  }
}
