import 'package:fpdart/fpdart.dart';
import 'package:split_ease/features/expenses/domain/usecases/create_expense_params.dart';
import 'package:split_ease/features/expenses/domain/usecases/update_expense_params.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_metadata_entity.dart';
import '../../../../core/error/failure.dart';
import 'package:split_ease/features/expenses/domain/entities/personal_expenses_entity.dart';

import 'package:split_ease/features/expenses/domain/entities/expense_media_entity.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, String>> createExpense(CreateExpenseParams params);
  Future<Either<Failure, void>> updateExpense(UpdateExpenseParams params);
  Future<Either<Failure, ExpenseDetailEntity>> getExpenseDetail(String expenseId);
  Future<Either<Failure, List<ExpenseCommentEntity>>> getExpenseComments(String expenseId);
  Future<Either<Failure, void>> deleteExpense(String expenseId);
  Future<Either<Failure, void>> restoreExpense(String expenseId);
  Future<Either<Failure, List<ExpenseUserEntity>>> getExpenseParticipants({String? groupId, String? friendUserId});
  Future<Either<Failure, void>> addExpenseComment({required String expenseId, required String comment});
  Future<Either<Failure, void>> updateExpenseComment({required String commentId, required String comment});
  Future<Either<Failure, void>> deleteExpenseComment({required String commentId});
  Future<Either<Failure, void>> settleUp({
    required String toUserId,
    required double amount,
    String? groupId,
    String? note,
  });
  Future<Either<Failure, ExpenseMetadataEntity>> getExpenseMetadata();
  Future<Either<Failure, PersonalExpensesEntity>> getPersonalExpenses();
  Future<Either<Failure, void>> attachExpenseMedia(String expenseId, List<ExpenseMediaEntity> media);
  Future<Either<Failure, void>> deleteExpenseMedia(String mediaId);
}
