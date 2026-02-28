import 'package:fpdart/fpdart.dart';
import 'package:split_ease/features/expenses/data/datasources/expense_remote_data_source.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';
import 'package:split_ease/features/expenses/domain/usecases/create_expense_params.dart';
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
}
