import 'package:fpdart/fpdart.dart';
import 'package:split_ease/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';
import 'package:split_ease/features/expenses/domain/usecases/create_expense_params.dart';
import 'package:split_ease/features/expenses/domain/usecases/update_expense_params.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_metadata_entity.dart';


import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import 'package:split_ease/features/expenses/domain/entities/personal_expenses_entity.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_media_entity.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> createExpense(CreateExpenseParams params) async {
    try {
      final expenseId = await remoteDataSource.createExpense(params);
      return Right(expenseId);
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
  Future<Either<Failure, List<ExpenseCommentEntity>>> getExpenseComments(String expenseId) async {
    try {
      final result = await remoteDataSource.getExpenseComments(expenseId);
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
  Future<Either<Failure, void>> updateExpenseComment({required String commentId, required String comment}) async {
    try {
      await remoteDataSource.updateExpenseComment(commentId: commentId, comment: comment);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpenseComment({required String commentId}) async {
    try {
      await remoteDataSource.deleteExpenseComment(commentId: commentId);
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

  @override
  Future<Either<Failure, ExpenseMetadataEntity>> getExpenseMetadata() async {
    try {
      final result = await remoteDataSource.getExpenseMetadata();
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PersonalExpensesEntity>> getPersonalExpenses() async {
    try {
      final result = await remoteDataSource.getPersonalExpenses();
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> attachExpenseMedia(String expenseId, List<ExpenseMediaEntity> media) async {
    try {
      await remoteDataSource.attachExpenseMedia(expenseId, media);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpenseMedia(String mediaId) async {
    try {
      await remoteDataSource.deleteExpenseMedia(mediaId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    }
  }
}
