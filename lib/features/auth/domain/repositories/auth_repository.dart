import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/auth/domain/entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity>> signUpWithEmailPassword({required String name, required String email, required String password});
  Future<Either<Failure, UserEntity>> loginWithEmailPassword({required String email, required String password});
}
