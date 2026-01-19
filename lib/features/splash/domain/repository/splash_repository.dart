import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/auth/domain/entities/user_entity.dart';

abstract interface class SplashRepository {
  Future<Either<Failure,UserEntity>> isUserActiveSession();
}
