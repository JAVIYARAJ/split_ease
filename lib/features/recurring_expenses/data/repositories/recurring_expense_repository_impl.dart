import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/recurring_expense_entity.dart';
import '../../domain/repositories/recurring_expense_repository.dart';
import '../datasources/recurring_expense_remote_data_source.dart';

class RecurringExpenseRepositoryImpl implements RecurringExpenseRepository {
  final RecurringExpenseRemoteDataSource remoteDataSource;

  RecurringExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<RecurringExpenseEntity>>> getRecurringExpenses() async {
    try {
      final result = await remoteDataSource.getRecurringExpenses();
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> saveRecurringExpense(
    RecurringExpenseEntity template, {
    bool isEdit = false,
  }) async {
    try {
      final result = await remoteDataSource.saveRecurringExpenseTemplate(
        templateId: isEdit ? template.id : null,
        title: template.title,
        amount: template.amount,
        categoryId: template.categoryId,
        frequency: template.frequency.name,
        dueDay: template.dueDay,
        autoRemind: template.autoRemind,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> togglePauseRecurringExpense(
    String templateId,
    bool isPaused,
  ) async {
    try {
      await remoteDataSource.togglePauseRecurringExpense(templateId, isPaused);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecurringExpense(String templateId) async {
    try {
      await remoteDataSource.deleteRecurringExpense(templateId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> confirmRecurringExpense(String templateId) async {
    try {
      await remoteDataSource.confirmRecurringExpense(templateId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
