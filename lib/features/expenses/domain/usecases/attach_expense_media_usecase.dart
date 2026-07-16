import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_media_entity.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';

class AttachExpenseMediaUseCase implements UseCase<void, AttachExpenseMediaParams> {
  final ExpenseRepository repository;

  AttachExpenseMediaUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AttachExpenseMediaParams params) async {
    return await repository.attachExpenseMedia(params.expenseId, params.media);
  }
}

class AttachExpenseMediaParams {
  final String expenseId;
  final List<ExpenseMediaEntity> media;

  AttachExpenseMediaParams({required this.expenseId, required this.media});
}
