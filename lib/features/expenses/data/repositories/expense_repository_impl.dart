import 'package:fpdart/fpdart.dart';
import 'package:split_ease/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';
import 'package:split_ease/features/expenses/domain/usecases/create_expense_params.dart';
import 'package:split_ease/features/expenses/domain/usecases/update_expense_params.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';


import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> createExpense(CreateExpenseParams params) async {
    try {
      await remoteDataSource.createExpense(params);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateExpense(UpdateExpenseParams params) async {
    try {
      await remoteDataSource.updateExpense(params);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseDetailEntity>> getExpenseDetail(String expenseId) async {
    try {
      final result = await remoteDataSource.getExpenseDetail(expenseId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
  @override
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    try {
      await remoteDataSource.deleteExpense(expenseId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restoreExpense(String expenseId) async {
    try {
      await remoteDataSource.restoreExpense(expenseId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseUserEntity>>> getExpenseParticipants({String? groupId, String? friendUserId}) async {
    try {
      final result = await remoteDataSource.getExpenseParticipants(groupId: groupId, friendUserId: friendUserId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addExpenseComment({required String expenseId, required String comment}) async {
    try {
      await remoteDataSource.addExpenseComment(expenseId: expenseId, comment: comment);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> settleUp({
    required String toUserId,
    required double amount,
    String? groupId,
    String? note,
  }) async {
    try {
      await remoteDataSource.settleUp(
        toUserId: toUserId,
        amount: amount,
        groupId: groupId,
        note: note,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
