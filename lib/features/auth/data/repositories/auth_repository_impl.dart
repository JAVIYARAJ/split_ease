import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:split_ease/features/auth/domain/entities/user_entity.dart';
import 'package:split_ease/features/auth/domain/repositories/auth_repository.dart';

import '../../../../core/error/exception.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl({required this.authRemoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailPassword({required String name, required String email, required String password}) async {
    try {
      var user = await authRemoteDataSource.signUpWithEmailPassword(name: name, email: email, password: password);
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithEmailPassword({required String email, required String password}) async {
    try {
      var user = await authRemoteDataSource.loginWithEmailPassword(email: email, password: password);
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await authRemoteDataSource.getCurrentUser();
      if (user != null) {
        return right(user);
      }
      return left(Failure(message: 'User not logged in'));
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resendConfirmationEmail({required String email}) async {
    try {
      await authRemoteDataSource.resendConfirmationEmail(email: email);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> signInWithGoogle() async {
    try {
      final user = await authRemoteDataSource.signInWithGoogle();
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}
