import 'package:fpdart/fpdart.dart';
import 'package:split_ease/features/expenses/domain/usecases/create_expense_params.dart';
import 'package:split_ease/features/expenses/domain/usecases/update_expense_params.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';
import '../../../../core/error/failure.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, void>> createExpense(CreateExpenseParams params);
  Future<Either<Failure, void>> updateExpense(UpdateExpenseParams params);
  Future<Either<Failure, ExpenseDetailEntity>> getExpenseDetail(String expenseId);
  Future<Either<Failure, void>> deleteExpense(String expenseId);
  Future<Either<Failure, void>> restoreExpense(String expenseId);
  Future<Either<Failure, List<ExpenseUserEntity>>> getExpenseParticipants({String? groupId, String? friendUserId});
  Future<Either<Failure, void>> addExpenseComment({required String expenseId, required String comment});
  Future<Either<Failure, void>> settleUp({
    required String toUserId,
    required double amount,
    String? groupId,
    String? note,
  });
  Future<Either<Failure, List<ExpenseCategoryEntity>>> getExpenseCategories();
}
